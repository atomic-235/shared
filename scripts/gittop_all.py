#!/usr/bin/env python3
"""Run gittop on a temporary clone whose HEAD reaches all remote branches.

gittop (go-git) cannot read linked worktrees ("object not found"), so this
uses a throwaway local clone with a synthetic octopus commit whose parents are
all branch tips, making the whole history reachable from a single HEAD.
"""

import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

IDENTITY = ["-c", "user.name=all-branches", "-c", "user.email=all-branches@local"]


def git(*args: str, check: bool = True) -> subprocess.CompletedProcess:
    return subprocess.run(["git", *args], check=check, capture_output=True, text=True)


def main() -> int:
    if shutil.which("gittop") is None:
        print("error: gittop not found (load the devShell with direnv)", file=sys.stderr)
        return 1

    repo = Path(git("rev-parse", "--show-toplevel").stdout.strip())

    tmp = Path(tempfile.mkdtemp(prefix="gittop-all-"))
    clone = tmp / "repo"
    try:
        git("clone", "--no-checkout", "--quiet", str(repo), str(clone))
        git("-C", str(clone), "fetch", "--quiet", "origin", "+refs/remotes/origin/*:refs/remotes/origin/*", check=False)

        refs = git("-C", str(clone), "for-each-ref", "--format=%(refname:short)", "refs/remotes/origin").stdout.splitlines()
        refs = [ref for ref in refs if not ref.endswith("/HEAD")]

        parents: list[str] = []
        for ref in ["HEAD", *refs]:
            sha = git("-C", str(clone), "rev-parse", ref, check=False)
            if sha.returncode == 0 and sha.stdout.strip() not in parents:
                parents.append(sha.stdout.strip())

        tree = git("-C", str(clone), "rev-parse", "HEAD^{tree}").stdout.strip()
        octopus = git(
            "-C",
            str(clone),
            *IDENTITY,
            "commit-tree",
            tree,
            *[arg for sha in parents for arg in ("-p", sha)],
            "-m",
            "all-branches snapshot",
        ).stdout.strip()
        git("-C", str(clone), "update-ref", "refs/heads/all", octopus)
        git("-C", str(clone), "symbolic-ref", "HEAD", "refs/heads/all")

        total = git("-C", str(clone), "rev-list", "--count", "HEAD").stdout.strip()
        print(f"branches: {len(refs)}, reachable commits: {total} (1 synthetic snapshot commit)")
        print("launching gittop...")
        subprocess.run(["gittop", str(clone)], check=False)
    finally:
        shutil.rmtree(tmp, ignore_errors=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
