import argparse
import os
import subprocess
import time
from pathlib import Path

CLK_TCK = os.sysconf("SC_CLK_TCK")
PAGE = os.sysconf("SC_PAGE_SIZE")

PANE_FMT = ("#{session_name}\t#{window_index}\t#{window_name}\t"
            "#{pane_index}\t#{pane_current_command}\t#{pane_pid}")


def snapshot():
    rss, ppid, cpu = {}, {}, {}
    for entry in Path("/proc").iterdir():
        if not entry.name.isdigit():
            continue
        try:
            stat = (entry / "stat").read_text()
            fields = stat[stat.rindex(")") + 2:].split()
            pid = int(entry.name)
            ppid[pid] = int(fields[1])
            cpu[pid] = int(fields[11]) + int(fields[12])
            statm = (entry / "statm").read_text()
            rss[pid] = int(statm.split()[1]) * PAGE
        except (FileNotFoundError, ProcessLookupError, IndexError,
                ValueError, PermissionError):
            continue
    return rss, ppid, cpu


def tree_sums(root, rss, ppid, cpu, cpu_prev, children):
    seen, stack = set(), [root]
    ram = cpu_delta = 0
    while stack:
        pid = stack.pop()
        if pid in seen:
            continue
        seen.add(pid)
        ram += rss.get(pid, 0)
        cpu_delta += cpu.get(pid, 0) - cpu_prev.get(pid, 0)
        stack.extend(children.get(pid, []))
    return ram, cpu_delta


def fmt_ram(ram_bytes):
    mib = ram_bytes / (1024 * 1024)
    if mib >= 1024:
        return f"{mib / 1024:.1f}G"
    return f"{mib:.0f}M"


def collect(roots, rss, ppid, cpu, cpu_prev):
    children = {}
    for pid, parent in ppid.items():
        children.setdefault(parent, []).append(pid)
    out = []
    for root in roots:
        ram, cpu_delta = tree_sums(root, rss, ppid, cpu, cpu_prev,
                                   children)
        out.append((root, ram, cpu_delta))
    return out


def main():
    parser = argparse.ArgumentParser(
        description="tmux session/window/pane RAM and CPU usage. "
                    "CPU percent is relative to one core.")
    parser.add_argument("level", nargs="?", default="sessions",
                        choices=["sessions", "windows", "panes"])
    parser.add_argument("-i", "--interval", type=float, default=0.5,
                        help="CPU sampling interval in seconds")
    parser.add_argument("-s", "--sort", default="ram",
                        choices=["ram", "cpu", "name"])
    args = parser.parse_args()

    res = subprocess.run(["tmux", "list-panes", "-a", "-F", PANE_FMT],
                         capture_output=True, text=True, check=False)
    if res.returncode != 0:
        print("tmux not running")
        return

    panes = []
    for line in res.stdout.splitlines():
        fields = line.split("\t")
        if len(fields) == 6 and fields[5].isdigit():
            panes.append(fields)

    rss1, ppid1, cpu1 = snapshot()
    time.sleep(args.interval)
    rss2, ppid2, cpu2 = snapshot()

    def pid_stats(pid):
        return collect([int(pid)], rss2, ppid2, cpu2, cpu1)[0]

    if args.level == "sessions":
        groups = {}
        for session, _, _, _, _, pid in panes:
            _, ram, cpu_delta = pid_stats(pid)
            sessions = groups.setdefault(session, [0, 0, 0])
            sessions[0] += 1
            sessions[1] += ram
            sessions[2] += cpu_delta
        rows = [(name, v[0], v[1], v[2]) for name, v in groups.items()]
        header = ("SESSION", "PANES", "RAM", "CPU")
        total = ("TOTAL", sum(r[1] for r in rows),
                 sum(r[2] for r in rows), sum(r[3] for r in rows))

    elif args.level == "windows":
        groups = {}
        for session, win, wname, _, _, pid in panes:
            _, ram, cpu_delta = pid_stats(pid)
            key = (f"{session}:{win}", wname)
            g = groups.setdefault(key, [0, 0, 0])
            g[0] += 1
            g[1] += ram
            g[2] += cpu_delta
        rows = [(k[0], k[1], v[0], v[1], v[2])
                for k, v in groups.items()]
        header = ("SESSION:WIN", "NAME", "PANES", "RAM", "CPU")
        total = ("TOTAL", "", sum(r[2] for r in rows),
                 sum(r[3] for r in rows), sum(r[4] for r in rows))

    else:
        rows = []
        for session, win, wname, pidx, cmd, pid in panes:
            _, ram, cpu_delta = pid_stats(int(pid))
            rows.append((f"{session}:{win}.{pidx}", cmd, int(pid),
                         ram, cpu_delta))
        header = ("PANE", "COMMAND", "PID", "RAM", "CPU")
        total = ("TOTAL", "", "", sum(r[3] for r in rows),
                 sum(r[4] for r in rows))

    ram_idx = 2 if args.level == "sessions" else 3
    if args.sort == "ram":
        rows.sort(key=lambda r: -r[ram_idx])
    elif args.sort == "cpu":
        rows.sort(key=lambda r: -r[-1])
    else:
        rows.sort(key=lambda r: r[0])

    cpu_col = args.interval * CLK_TCK

    def cpu_fmt(delta):
        return f"{delta / cpu_col * 100:5.1f}%"

    print("\t".join(header))
    for row in rows:
        if args.level == "sessions":
            name, np, ram, cd = row
            print(f"{name}\t{np}\t{fmt_ram(ram)}\t{cpu_fmt(cd)}")
        elif args.level == "windows":
            key, wname, np, ram, cd = row
            print(f"{key}\t{wname}\t{np}\t{fmt_ram(ram)}\t{cpu_fmt(cd)}")
        else:
            pane, cmd, pid, ram, cd = row
            print(f"{pane}\t{cmd}\t{pid}\t{fmt_ram(ram)}\t{cpu_fmt(cd)}")
    if args.level == "sessions":
        print(f"{total[0]}\t{total[1]}\t{fmt_ram(total[2])}"
              f"\t{cpu_fmt(total[3])}")
    elif args.level == "windows":
        print(f"{total[0]}\t\t{total[2]}\t{fmt_ram(total[3])}"
              f"\t{cpu_fmt(total[4])}")
    else:
        print(f"{total[0]}\t\t\t{fmt_ram(total[3])}\t{cpu_fmt(total[4])}")


if __name__ == "__main__":
    main()
