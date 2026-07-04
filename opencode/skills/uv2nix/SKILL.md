---
name: uv2nix
description: Set up and maintain Python projects with uv2nix flakes on NixOS, including direnv integration, setuptools overrides, and older Python via pinned nixpkgs
---

## What I do
- Write `flake.nix` for Python projects using uv2nix
- Configure `.envrc` for direnv (`use flake`)
- Handle packages that require setuptools or native C libraries
- Handle older Python versions (3.10, 3.11) via pinned nixpkgs channels
- Set correct UV env vars so uv and the Nix-built venv stay in sync
- Wrap Python in a bubblewrap (bwrap) sandbox by default
- Measure build performance with verbose timestamped logging before declaring a build slow

## System context
- NixOS with `nixos-unstable` as the primary channel
- direnv + nix-direnv enabled globally (`programs.direnv.nix-direnv.enable = true`)
- `.envrc` is always just `use flake` — nix-direnv handles caching
- All projects are `x86_64-linux` only; no `flake-utils` / `eachDefaultSystem`

---

## Canonical flake.nix skeleton

```nix
{
  description = "<project description>";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    uv2nix = {
      url = "github:pyproject-nix/uv2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pyproject-nix = {
      url = "github:pyproject-nix/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pyproject-build-systems = {
      url = "github:pyproject-nix/build-system-pkgs";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, uv2nix, pyproject-nix, pyproject-build-systems }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      workspace = uv2nix.lib.workspace.loadWorkspace { workspaceRoot = ./.; };
      overlay = workspace.mkPyprojectOverlay { sourcePreference = "wheel"; };

      python = pkgs.python312;  # see python-compat section for older versions

      pythonSet =
        (pkgs.callPackage pyproject-nix.build.packages { inherit python; })
        .overrideScope (pkgs.lib.composeManyExtensions [
          pyproject-build-systems.overlays.default
          overlay
          # pyprojectOverrides  # add if needed — see overrides section
        ]);

      venv = pythonSet.mkVirtualEnv "<project-name>-env" {
        <project-name> = [];          # [] = default extras, or e.g. [ "dev" ]
      };

      # Python wrapped in a bubblewrap sandbox — always do this by default
      pythonBwrap = pkgs.writeShellScriptBin "python" ''
        exec ${pkgs.bubblewrap}/bin/bwrap \
          --ro-bind /nix/store /nix/store \
          --ro-bind /etc /etc \
          --bind /tmp /tmp \
          --bind "$(pwd)" "$(pwd)" \
          --dev /dev \
          --proc /proc \
          --die-with-parent \
          -- ${venv}/bin/python "$@"
      '';
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = [ pythonBwrap venv pkgs.uv pkgs.bubblewrap pkgs.pyright ];
        env = {
          UV_NO_SYNC             = "1";
          UV_PYTHON              = "${pythonBwrap}/bin/python";
          UV_PYTHON_DOWNLOADS    = "never";
          UV_PROJECT_ENVIRONMENT = "${venv}";
        };
        shellHook = ''unset PYTHONPATH'';
      };
    };
}
```

## .envrc
Always exactly one line:
```
use flake
```
After creating/changing `flake.nix` run `direnv allow` once.

---

## mkVirtualEnv dependency spec
The second argument to `mkVirtualEnv` maps package names to their extras list:

```nix
# Install project with no extras (default deps only)
venv = pythonSet.mkVirtualEnv "my-env" { my-project = []; };

# Include optional-dependency group "dev"
venv = pythonSet.mkVirtualEnv "my-env" { my-project = [ "dev" ]; };

# workspace.deps.default — reads [project.dependencies] from pyproject.toml
venv = pythonSet.mkVirtualEnv "my-env" workspace.deps.default;

# workspace.deps.all — all deps including optional groups (used with editable overlay)
editableVenv = editablePythonSet.mkVirtualEnv "my-dev-env" workspace.deps.all;
```

The package name **must** match `[project.name]` in `pyproject.toml` exactly (hyphens, not underscores).

---

## Overrides: packages missing build-system declarations

### setuptools — single package
Use when a package builds from sdist and has no `[build-system]` in its own metadata:

```nix
pyprojectOverrides = final: prev: {
  some-package = prev.some-package.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or []) ++ final.resolveBuildSystem {
      setuptools = [];
    };
  });
};
```

### setuptools — multiple legacy packages (reusable helper)
Use when several packages need the same treatment (e.g. pyspark, hdfs, antlr4, docopt):

```nix
pyprojectOverrides = final: prev:
  let
    addBuildSystem = pkg: systems: pkg.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or []) ++
        (map (s: if builtins.isString s then final.${s} else s) systems);
    });
  in {
    docopt                = addBuildSystem prev.docopt                [ "setuptools" ];
    antlr4-python3-runtime = addBuildSystem prev.antlr4-python3-runtime [ "setuptools" ];
    hdfs                  = addBuildSystem prev.hdfs                  [ "setuptools" ];
    pyspark               = addBuildSystem prev.pyspark               [ "setuptools" ];
  };
```

### setuptools via `final.setuptools` (alternative form)
Older style; still works, less idiomatic:

```nix
streamlit-authenticator = prev.streamlit-authenticator.overrideAttrs (old: {
  nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ final.setuptools ];
});
```

---

## Overrides: native C library dependencies

### pyodbc (unixODBC)
```nix
pyprojectOverrides = final: prev: {
  pyodbc = prev.pyodbc.overrideAttrs (old: {
    buildInputs = (old.buildInputs or []) ++ [ pkgs.unixODBC ];
  });
};
```

### MS SQL Server ODBC driver (msodbcsql18 — unfree)
Must allow unfree in nixpkgs instantiation AND set up odbcinst.ini:

```nix
pkgs = import nixpkgs {
  inherit system;
  config.allowUnfreePredicate = pkg:
    builtins.elem (nixpkgs.lib.getName pkg) [ "msodbcsql18" ];
};

msodbcsql = pkgs.unixODBCDrivers.msodbcsql18;

odbcinstDir = pkgs.runCommand "odbc-config" {} ''
  mkdir -p $out
  cat > $out/odbcinst.ini <<EOF
[ODBC Driver 18 for SQL Server]
Description = Microsoft ODBC Driver 18 for SQL Server
Driver = ${msodbcsql}/lib/libmsodbcsql-18.1.so.1.1
EOF
'';
```

devShell env + hook for ODBC:
```nix
packages = [ venv pkgs.uv pkgs.unixODBC msodbcsql pkgs.sops pkgs.pyright ];
env = {
  UV_NO_SYNC            = "1";
  UV_PYTHON             = "${venv}/bin/python";
  UV_PYTHON_DOWNLOADS   = "never";
  UV_PROJECT_ENVIRONMENT = "${venv}";
  ODBCSYSINI            = "${odbcinstDir}";
};
shellHook = ''
  unset PYTHONPATH
  unset ODBCINSTINI
  export ODBCSYSINI=${odbcinstDir}
  export LD_LIBRARY_PATH="${pkgs.unixODBC}/lib:${msodbcsql}/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
'';
```

### Other native extras
```nix
# PySpark needs a JRE
packages = [ venv pkgs.uv pkgs.jdk17_headless ];
shellHook = ''
  unset PYTHONPATH
  export JAVA_HOME="${pkgs.jdk17_headless}"
'';

# Gurobi / GLPK LP solvers
packages = [ venv pkgs.uv pkgs.glpk ];
shellHook = ''
  unset PYTHONPATH
  export GLPSOL_PATH="${pkgs.glpk}/bin/glpsol"
'';
```

---

## Python version compatibility

### Default: use nixpkgs-unstable
nixpkgs-unstable ships Python 3.12 and 3.13. Always prefer these unless the project pins an older version.

```nix
python = pkgs.python312;   # or pkgs.python313
```

### Older Python (3.10, 3.11) — nixos-24.11
nixpkgs-unstable dropped Python 3.10. Use a secondary pinned input for the interpreter only:

```nix
inputs = {
  nixpkgs.url     = "github:NixOS/nixpkgs/nixpkgs-unstable";
  nixpkgs-py310.url = "github:NixOS/nixpkgs/nixos-24.11";  # ships python310

  # uv2nix ecosystem still follows main nixpkgs
  uv2nix.inputs.nixpkgs.follows = "nixpkgs";
  pyproject-nix.inputs.nixpkgs.follows = "nixpkgs";
  pyproject-build-systems.inputs.nixpkgs.follows = "nixpkgs";
};

outputs = { self, nixpkgs, nixpkgs-py310, uv2nix, pyproject-nix, pyproject-build-systems }:
  let
    system      = "x86_64-linux";
    pkgs        = import nixpkgs       { inherit system; };
    pkgs-py310  = import nixpkgs-py310 { inherit system; };

    python = pkgs-py310.python310;   # interpreter from pinned channel
    # pythonSet still built with main pkgs (tools, stdenv, etc.)
    pythonSet = (pkgs.callPackage pyproject-nix.build.packages { inherit python; }) ...
```

Key rule: `python` comes from the pinned `pkgs-py310`, but `pkgs.callPackage` (tools, stdenv, glibc) stays on `nixpkgs-unstable`. Never swap the whole `pkgs` to the pinned channel — that drags in an older stdenv for everything.

### nixos-24.11 channel reference
| Python | nixpkgs channel |
|--------|----------------|
| 3.13   | nixpkgs-unstable |
| 3.12   | nixpkgs-unstable |
| 3.11   | nixpkgs-unstable |
| 3.10   | nixos-24.11 |
| 3.9    | nixos-23.11 |

---

## Editable installs (development with live reload)

```nix
editableOverlay = workspace.mkEditablePyprojectOverlay {
  root = "$REPO_ROOT";   # resolved at shell entry via shellHook
};

editablePythonSet = pythonSet.overrideScope editableOverlay;
editableVenv = editablePythonSet.mkVirtualEnv "my-dev-env" workspace.deps.all;

devShells.${system}.default = pkgs.mkShell {
  packages = [ editableVenv pkgs.uv ];
  env = {
    UV_NO_SYNC          = "1";
    UV_PYTHON           = pythonSet.python.interpreter;  # raw interpreter, not venv/bin/python
    UV_PYTHON_DOWNLOADS = "never";
  };
  shellHook = ''
    unset PYTHONPATH
    export REPO_ROOT=$(git rev-parse --show-toplevel)
  '';
};
```

Note: when using the editable overlay, set `UV_PYTHON = pythonSet.python.interpreter` (not `${venv}/bin/python`).

---

## pyproject.toml build backend

Use `setuptools` for all projects unless there is a specific reason not to. It requires no package directory structure and works for script-only projects:

```toml
[build-system]
requires = ["setuptools"]
build-backend = "setuptools.build_meta"
```

**Do not use `hatchling`** unless the project has a proper package directory matching `[project.name]` (hyphens → underscores). Hatchling will fail with `ValueError: Unable to determine which files to ship inside the wheel` if no such directory exists. It also picks up the `result` symlink created by `nix build` and fails trying to stat it.

---

## Known sdist-only packages (always need setuptools override)

These packages ship no wheels on PyPI and will fail to build without the override:

```nix
pyprojectOverrides = final: prev: {
  # yfinance dependency — sdist only, no pyproject.toml build-system declared
  multitasking = prev.multitasking.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or []) ++ final.resolveBuildSystem {
      setuptools = [];
    };
  });
};
```

Always add this override when `yfinance` is a dependency.

---

## Bubblewrap sandbox for Python

Always wrap the Python interpreter in a bwrap sandbox. This restricts what Python code can access at runtime. The wrapper is a `writeShellScriptBin` derivation named `python` that execs `bwrap` around the real venv Python. Point `UV_PYTHON` at the wrapper so all uv invocations use the sandboxed interpreter.

Default bind mounts:
- `/nix/store` — read-only (all Nix-built libs live here)
- `/etc` — read-only (timezone, certs, nsswitch)
- `/tmp` — read-write
- `$(pwd)` — read-write (project files)
- `/dev`, `/proc` — standard pseudo-filesystems

Add more `--bind` / `--ro-bind` lines if the project needs access to additional paths (e.g. `$HOME/.config`, a data directory).

---

## Measuring build performance

Before concluding a build is slow, always measure with verbose timestamped logging:

```bash
nix build .#devShells.x86_64-linux.default --log-format bar-with-logs -v 2>&1 \
  | awk '{ print strftime("[%H:%M:%S]"), $0; fflush() }' \
  | tee /tmp/nix-build.log
```

Then extract the actual build steps to see where time is spent:

```bash
grep -E '^\[.*\] (building|copying path|fetching)' /tmp/nix-build.log
```

Key distinction:
- Lines before the first `building` line = **Nix evaluation** (loading nixpkgs + uv2nix overlays, ~5s, unavoidable)
- `building` lines = **actual derivation builds** (the part that matters)
- `copying path` lines = **binary cache fetches** (network bound)

The actual builds for a minimal uv2nix project take ~4 seconds. Evaluation overhead is fixed regardless of project size.

To check what still needs to be built before committing to a full build:

```bash
nix build .#devShells.x86_64-linux.default --dry-run
```

To check which packages will compile from source (sdist-only, no wheels):

```bash
python3 -c "
import re
content = open('uv.lock').read()
packages = re.split(r'\n\[\[package\]\]\n', content)
for p in packages:
    name = re.search(r'^name = \"(.+?)\"', p, re.M)
    if name and 'wheels' not in p and 'sdist' in p:
        print(name.group(1))
"
```

---

## Pyright / LSP configuration

Pyright picks up the correct Python automatically when the editor respects direnv. No `pyproject.toml` or `pyrightconfig.json` configuration is needed. If you see import errors in the editor, the cause is the editor not loading the direnv environment — fix it at the editor level (e.g. `direnv.vim`, VS Code direnv extension), not in the project config.

**Do not** hardcode nix store paths in `pyproject.toml` — they are machine- and rebuild-specific and will break on any other system.

LSP errors reported by an agent running outside the direnv shell are false positives and can be ignored. The imports resolve correctly at runtime.

---

## AGENTS.md

After setting up the flake, always create or update `AGENTS.md` in the **project root** with instructions for agents on how to use Python and install dependencies. Example content:

```markdown
## Python environment

This project uses uv2nix. The environment is managed by Nix — do not use pip or create virtualenvs manually.

**Run Python:**
```bash
python <script.py>
```

**Add a dependency:**
1. Add it to `[project.dependencies]` in `pyproject.toml`
2. Run `UV_PYTHON="" UV_PYTHON_DOWNLOADS=never uv lock` to update `uv.lock`
3. Run `touch flake.nix && direnv reload` to rebuild the environment

**Run a command in the environment:**
```bash
uv run <command>
```

Do not run `uv sync`, `pip install`, or `python -m venv`. The venv is built by Nix and is read-only.


```

---

## Common mistakes to avoid

- **Never** omit `pyproject-build-systems.overlays.default` from `composeManyExtensions` — it provides flit, hatch, setuptools for packages that declare them as build-system.
- **Never** set `UV_PROJECT_ENVIRONMENT` pointing outside the nix store venv — uv will try to mutate it.
- **Don't** use `nixpkgs.legacyPackages.${system}` when you need unfree packages — use `import nixpkgs { config.allowUnfreePredicate = ...; }` instead.
- **Don't** swap the entire `pkgs` to a pinned channel for older Python — only pull the `python` attribute from it.
- **Don't** use `hatchling` as build backend unless the project has a matching package directory.
- **Don't** suggest switching to nixpkgs Python packages unless the user explicitly asks — uv2nix is intentional.
- **Always** `unset PYTHONPATH` in `shellHook` — stale PYTHONPATH leaks break imports.
- **Always** run `UV_PYTHON="" UV_PYTHON_DOWNLOADS=never uv lock` after changing `pyproject.toml` — never plain `uv lock` or `uv add`, because `UV_PYTHON` points to the bwrap wrapper which cannot be queried outside a live shell and will error.
- **Always** run scripts via `direnv exec <project-dir> <command>` when outside an interactive shell — otherwise the wrong Python is used and imports fail.
- **Always** bust the nix-direnv cache after a rebuild by running `touch flake.nix` if `direnv exec` is still loading a stale shell (recognizable by the old venv path in `$UV_PROJECT_ENVIRONMENT`).
- **Always** check for sdist-only deps (especially transitive ones like `multitasking` from yfinance) and add setuptools overrides.
- **Always** wrap Python in a bwrap sandbox via `writeShellScriptBin` and point `UV_PYTHON` at the wrapper.
- **Never** hardcode nix store paths in `pyproject.toml` for pyright — they are machine-specific. LSP works automatically when the editor respects direnv. Import errors seen by agents running outside the shell are false positives.
- **Never** guess why a build is slow — measure first with `--log-format bar-with-logs -v` and timestamps.
