import os
import re
import subprocess
import sys
from pathlib import Path


def run(cmd, **kw):
    return subprocess.run(cmd, capture_output=True, text=True,
                          check=False, **kw)


def proc_table():
    page = os.sysconf("SC_PAGE_SIZE")
    rss, ppid = {}, {}
    for entry in Path("/proc").iterdir():
        if not entry.name.isdigit():
            continue
        try:
            stat = (entry / "stat").read_text()
            fields = stat[stat.rindex(")") + 2:].split()
            pid = int(entry.name)
            ppid[pid] = int(fields[1])
            statm = (entry / "statm").read_text()
            rss[pid] = int(statm.split()[1]) * page
        except (FileNotFoundError, ProcessLookupError, IndexError,
                ValueError, PermissionError):
            continue
    return rss, ppid


def tree_rss(root, rss, ppid):
    children = {}
    for pid, parent in ppid.items():
        children.setdefault(parent, []).append(pid)
    seen, stack, total = set(), [root], 0
    while stack:
        pid = stack.pop()
        if pid in seen:
            continue
        seen.add(pid)
        total += rss.get(pid, 0)
        stack.extend(children.get(pid, []))
    return total


def session_ram(name):
    res = run(["tmux", "list-panes", "-s", "-t", name, "-F", "#{pane_pid}"])
    if res.returncode != 0:
        return 0
    rss, ppid = proc_table()
    return sum(tree_rss(int(p), rss, ppid)
               for p in res.stdout.split() if p.isdigit())


def has_session(name):
    return run(["tmux", "has-session", "-t=" + name]).returncode == 0


def main():
    default_dir = sys.argv[1] if len(sys.argv) > 1 else "~/projects"
    search_dir = os.path.expanduser(default_dir).rstrip("/")

    entries = []
    for d in sorted(Path(search_dir).glob("*")):
        if not d.is_dir():
            continue
        entries.append(str(d))
        gitmodules = d / ".gitmodules"
        if gitmodules.exists():
            for line in gitmodules.read_text().splitlines():
                m = re.search(r"path\s*=\s*(\S+)", line)
                if m and (d / m.group(1)).is_dir():
                    entries.append(str(d / m.group(1)))

    cache = Path(os.environ.get("XDG_CACHE_HOME", "~/.cache")).expanduser()
    mru_file = cache / ("tmux-sessionizer-mru-"
                        + re.sub(r"[ /]", "__", search_dir))
    mru = []
    if mru_file.exists():
        mru = [line for line in mru_file.read_text().splitlines() if line]
    seen = set(mru)
    sorted_entries = [e for e in mru if os.path.isdir(e)]
    sorted_entries += [e for e in entries if e not in seen]

    display = []
    for entry in sorted_entries:
        sname = os.path.basename(entry).replace(".", "_")
        if has_session(sname):
            ram = session_ram(sname) // (1024 * 1024)
            display.append(f"{entry} ({ram}M)")
        else:
            display.append(entry)

    res = run(["fzf", "--no-sort", "--print-query", "--expect=ctrl-n"],
              input="\n".join(display))
    lines = res.stdout.splitlines()
    query = lines[0] if lines else ""
    key = lines[1] if len(lines) > 1 else ""
    selected = lines[2] if len(lines) > 2 else ""
    selected = re.sub(r" \(\d+M\)$", "", selected)

    if not selected and not query:
        return

    if key == "ctrl-n" or (not selected and query):
        selected = f"{search_dir}/{query}"
        os.makedirs(selected, exist_ok=True)

    mru_new = [selected] + [line for line in mru if line != selected]
    mru_file.parent.mkdir(parents=True, exist_ok=True)
    mru_file.write_text("\n".join(mru_new[:50]) + "\n")

    selected_name = os.path.basename(selected).replace(".", "_")
    tmux_running = run(["pgrep", "tmux"]).returncode == 0

    in_tmux = bool(os.environ.get("TMUX"))
    if not in_tmux and not tmux_running:
        run(["tmux", "new-session", "-s", selected_name, "-c", selected])
        return

    if not has_session(selected_name):
        run(["tmux", "new-session", "-ds", selected_name,
             "-n", "bash", "-c", selected])
        run(["tmux", "new-window", "-t", selected_name,
             "-n", "nvim", "-c", selected])

        if os.path.isfile(os.path.join(selected, ".envrc")):
            nvim_cmd = "direnv exec . nvim . || nvim ."
        elif os.path.isdir(os.path.join(selected, ".venv")):
            nvim_cmd = f"source {selected}/.venv/bin/activate && nvim ."
        else:
            nvim_cmd = "nvim ."
        run(["tmux", "send-keys", "-t", f"{selected_name}:nvim",
             nvim_cmd, "C-m"])

        run(["tmux", "new-window", "-t", selected_name,
             "-n", "ai", "-c", selected])
        if "/share," in os.environ.get("TMUX", ""):
            ai_cmd = os.environ.get("SESSIONIZER_AI_CMD_WORK",
                                    "work-opencode")
        else:
            ai_cmd = os.environ.get("SESSIONIZER_AI_CMD", "opencode")
        run(["tmux", "send-keys", "-t", f"{selected_name}:ai",
             ai_cmd, "C-m"])

        run(["tmux", "select-window", "-t", f"{selected_name}:bash"])
        if os.path.isfile(os.path.join(selected, ".tmux")):
            run(["tmux", "set-environment", "-t", selected_name,
                 "PROJECT_ROOT", selected])
            run(["tmux", "source-file", os.path.join(selected, ".tmux")])

    run(["tmux", "switch-client", "-t", selected_name])


if __name__ == "__main__":
    main()
