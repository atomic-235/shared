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
    rss, ppid, cpu, comm = {}, {}, {}, {}
    for entry in Path("/proc").iterdir():
        if not entry.name.isdigit():
            continue
        try:
            stat = (entry / "stat").read_text()
            fields = stat[stat.rindex(")") + 2:].split()
            pid = int(entry.name)
            ppid[pid] = int(fields[1])
            cpu[pid] = int(fields[11]) + int(fields[12])
            comm[pid] = stat[stat.index("(") + 1:stat.rindex(")")]
            statm = (entry / "statm").read_text()
            rss[pid] = int(statm.split()[1]) * PAGE
        except (FileNotFoundError, ProcessLookupError, IndexError,
                ValueError, PermissionError):
            continue
    return rss, ppid, cpu, comm


def children_map(ppid):
    children = {}
    for pid, parent in ppid.items():
        children.setdefault(parent, []).append(pid)
    return children


def subtree(pid, children):
    out, stack = set(), [pid]
    while stack:
        cur = stack.pop()
        if cur in out:
            continue
        out.add(cur)
        stack.extend(children.get(cur, []))
    return out


def tree_sums(root, rss, cpu, cpu_prev, children):
    sub = subtree(root, children)
    ram = sum(rss.get(p, 0) for p in sub)
    delta = sum(cpu.get(p, 0) - cpu_prev.get(p, 0) for p in sub)
    return ram, delta


def fmt_ram(ram_bytes):
    mib = ram_bytes / (1024 * 1024)
    if mib >= 1024:
        return f"{mib / 1024:.1f}G"
    return f"{mib:.0f}M"


def print_table(header, table, n_left):
    widths = [len(h) for h in header]
    for row in table:
        for i, cell in enumerate(row):
            widths[i] = max(widths[i], len(str(cell)))
    lines = []
    for row in [list(header)] + table:
        cells = []
        for i, cell in enumerate(row):
            cell = str(cell)
            if i < n_left:
                cells.append(cell.ljust(widths[i]))
            else:
                cells.append(cell.rjust(widths[i]))
        lines.append("  ".join(cells).rstrip())
    print("\n".join(lines))


def server_sockets():
    uid = os.getuid()
    sockets = []
    env_socket = os.environ.get("TMUX", "").split(",")[0]
    if env_socket:
        sockets.append(env_socket)
    dirs = [Path("/tmp") / f"tmux-{uid}"]
    for var in ("TMUX_TMPDIR", "XDG_RUNTIME_DIR"):
        val = os.environ.get(var)
        if val:
            d = Path(val) / f"tmux-{uid}"
            if d not in dirs:
                dirs.append(d)
    for d in dirs:
        if not d.is_dir():
            continue
        for sock in sorted(d.iterdir()):
            if str(sock) not in sockets:
                sockets.append(str(sock))
    live = []
    for sock in sockets:
        res = subprocess.run(["tmux", "-S", sock, "list-sessions"],
                             capture_output=True, text=True, check=False)
        if res.returncode == 0:
            live.append(sock)
    return live


def server_label(sock):
    path = Path(sock)
    parts = path.parts
    if len(parts) >= 4:
        return f"{parts[1]}/{path.name}"
    return str(path)


def main():
    parser = argparse.ArgumentParser(
        description="tmux session/window/pane RAM and CPU usage across "
                    "all tmux servers, plus orphan processes not under "
                    "any server. CPU percent is relative to one core.")
    parser.add_argument("level", nargs="?", default="sessions",
                        choices=["sessions", "windows", "panes"])
    parser.add_argument("-i", "--interval", type=float, default=0.5,
                        help="CPU sampling interval in seconds")
    parser.add_argument("-s", "--sort", default="ram",
                        choices=["ram", "cpu", "name"])
    parser.add_argument("--no-orphans", action="store_true",
                        help="hide the orphans section")
    args = parser.parse_args()

    panes = []
    for sock in server_sockets():
        res = subprocess.run(["tmux", "-S", sock, "list-panes", "-a",
                              "-F", PANE_FMT],
                             capture_output=True, text=True, check=False)
        if res.returncode != 0:
            continue
        for line in res.stdout.splitlines():
            fields = line.split("\t")
            if len(fields) == 6 and fields[5].isdigit():
                panes.append((server_label(sock), *fields))

    rss1, _, cpu1, _ = snapshot()
    time.sleep(args.interval)
    rss2, ppid2, cpu2, comm2 = snapshot()
    children = children_map(ppid2)

    cpu_col = max(args.interval, 0.001) * CLK_TCK

    def cpu_fmt(delta):
        return f"{delta / cpu_col * 100:5.1f}%"

    def pid_stats(pid):
        return tree_sums(int(pid), rss2, cpu2, cpu1, children)

    rows = []
    if args.level == "sessions":
        header = ("SERVER", "SESSION", "PANES", "RAM", "CPU")
        groups = {}
        for pane in panes:
            srv, session = pane[0], pane[1]
            ram, cd = pid_stats(pane[6])
            g = groups.setdefault((srv, session), [0, 0, 0])
            g[0] += 1
            g[1] += ram
            g[2] += cd
        rows = [(srv, name, v[0], v[1], v[2])
                for (srv, name), v in groups.items()]

    elif args.level == "windows":
        header = ("SERVER", "SESSION:WIN", "NAME", "PANES", "RAM", "CPU")
        groups = {}
        for pane in panes:
            srv, session, win, wname = pane[0], pane[1], pane[2], pane[3]
            ram, cd = pid_stats(pane[6])
            key = (srv, f"{session}:{win}", wname)
            g = groups.setdefault(key, [0, 0, 0])
            g[0] += 1
            g[1] += ram
            g[2] += cd
        rows = [(k[0], k[1], k[2], v[0], v[1], v[2])
                for k, v in groups.items()]

    else:
        header = ("SERVER", "PANE", "COMMAND", "PID", "RAM", "CPU")
        for pane in panes:
            srv, session, win, wname, pidx, cmd, pid = pane
            ram, cd = pid_stats(pid)
            rows.append((srv, f"{session}:{win}.{pidx}", cmd, pid,
                         ram, cd))

    if panes:
        ram_idx = len(header) - 2
        if args.sort == "ram":
            rows.sort(key=lambda r: -r[ram_idx])
        elif args.sort == "cpu":
            rows.sort(key=lambda r: -r[-1])
        else:
            rows.sort(key=lambda r: (r[0], r[1]))

        table = []
        for row in rows:
            cells = list(row[:-2])
            cells.append(fmt_ram(row[-2]))
            cells.append(cpu_fmt(row[-1]))
            table.append(cells)
        total_ram = sum(r[-2] for r in rows)
        total_cpu = sum(r[-1] for r in rows)
        filler = [""] * (len(header) - 4)
        table.append(["TOTAL", *filler, fmt_ram(total_ram),
                      cpu_fmt(total_cpu)])
        print_table(header, table, len(header) - 3)

    if args.no_orphans:
        return

    covered = set()
    server_pids = set()
    for pane in panes:
        pid = int(pane[6])
        covered |= subtree(pid, children)
        parent = ppid2.get(pid)
        if parent is not None:
            server_pids.add(parent)
    excluded = {1, 2} | subtree(2, children)
    residual = set(ppid2) - covered - server_pids - excluded
    roots = sorted(p for p in residual if ppid2.get(p, 0) not in residual)

    orphan_rows = []
    for root in roots:
        ram, cd = tree_sums(root, rss2, cpu2, cpu1, children)
        orphan_rows.append((root, comm2.get(root, "?"), ram, cd))
    orphan_rows.sort(key=lambda r: -r[2])

    print()
    print("ORPHANS (not under any tmux server)")
    o_header = ("PID", "COMMAND", "RAM", "CPU")
    o_table = []
    for pid, cmd, ram, cd in orphan_rows:
        o_table.append([pid, cmd, fmt_ram(ram), cpu_fmt(cd)])
    total_ram = sum(r[2] for r in orphan_rows)
    total_cpu = sum(r[3] for r in orphan_rows)
    o_table.append(["TOTAL", "", fmt_ram(total_ram), cpu_fmt(total_cpu)])
    print_table(o_header, o_table, 1)


if __name__ == "__main__":
    main()
