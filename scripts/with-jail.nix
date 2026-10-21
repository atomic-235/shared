{ pkgs }:

pkgs.writeShellApplication {
  name = "with-jail";
  runtimeInputs = [
    pkgs.bubblewrap
    pkgs.coreutils
    pkgs.git
  ];
  text = ''
    set -euo pipefail

    prog=''${0##*/}

    usage() {
      cat >&2 <<'EOF'
    Usage: with-jail [OPTIONS] [--] COMMAND [ARG...]

    Run COMMAND inside a bubblewrap sandbox:
      * $HOME is an empty tmpfs
      * /proc is private to the jail
      * /nix/store, /etc, /sys and the current system profile are read-only
      * the current git worktree (or $PWD) is read-write
      * the network is shared unless --no-net is given
      * package-manager caches under $HOME are shared (disable with --no-caches)
      * variables that look like secrets are dropped from the environment

    Options:
      --no-net           unshare the network namespace
      --no-caches        do not share package-manager caches (uv, npm, cargo, go)
      --ro PATH          extra read-only bind (repeatable)
      --rw PATH          extra read-write bind (repeatable)
      --clear-env        keep only PATH, TERM, LANG, LC_*, TZ, NIX_* and proxy vars
      --keep-env NAME    keep NAME even if it looks like a secret (repeatable)
      -h, --help         show this help
    EOF
    }

    no_net=0
    clear_env=0
    use_caches=1
    ro_binds=()
    rw_binds=()
    keep_envs=()

    while (( $# > 0 )); do
      case $1 in
        --no-net)
          no_net=1
          shift
          ;;
        --no-caches)
          use_caches=0
          shift
          ;;
        --clear-env)
          clear_env=1
          shift
          ;;
        --ro | --rw | --keep-env)
          if (( $# < 2 )); then
            echo "$prog: $1 requires an argument" >&2
            exit 2
          fi
          case $1 in
            --ro) ro_binds+=("$(realpath "$2")") ;;
            --rw) rw_binds+=("$(realpath "$2")") ;;
            --keep-env) keep_envs+=("$2") ;;
          esac
          shift 2
          ;;
        -h | --help)
          usage
          exit 0
          ;;
        --)
          shift
          break
          ;;
        -?*)
          echo "$prog: unknown option: $1" >&2
          usage
          exit 2
          ;;
        *) break ;;
      esac
    done

    if (( $# == 0 )); then
      usage
      exit 2
    fi

    workdir=$PWD
    if ! root=$(git -C "$workdir" rev-parse --show-toplevel 2>/dev/null); then
      root=$workdir
    fi
    gitdir=$(git -C "$workdir" rev-parse --absolute-git-dir 2>/dev/null || true)

    if [[ $root == "$HOME" || $root == "/" ]]; then
      echo "$prog: refusing to bind $root read-write (run from a project directory)" >&2
      exit 2
    fi

    args=(
      --clearenv
      --die-with-parent
      --new-session
      --unshare-all
      --hostname jail
      --cap-drop ALL
      --proc /proc
      --dev /dev
      --tmpfs /tmp
      --dir /tmp/xdg
    )

    home_parent=$(dirname "$HOME")
    if [[ $home_parent != "/" ]]; then
      args+=(--dir "$home_parent")
    fi
    args+=(--tmpfs "$HOME")

    # Nix profiles live under $HOME; expose them read-only so tools on PATH work.
    for p in "$HOME/.nix-profile" "$HOME/.local/state/nix"; do
      if [[ -e $p ]]; then
        args+=(--ro-bind "$p" "$p")
      fi
    done

    if (( no_net == 0 )); then
      args+=(--share-net)
    fi

    args+=(
      --ro-bind /nix/store /nix/store
      --ro-bind /etc /etc
      --bind "$root" "$root"
      --chdir "$workdir"
    )

    if [[ -n $gitdir && $gitdir != "$root"/* ]]; then
      args+=(--bind "$gitdir" "$gitdir")
    fi

    if [[ -d /run/current-system ]]; then
      args+=(--ro-bind /run/current-system /run/current-system)
    fi
    if [[ -d /sys ]]; then
      args+=(--ro-bind /sys /sys)
    fi
    if [[ -S /nix/var/nix/daemon-socket/socket ]]; then
      args+=(--ro-bind /nix/var/nix/daemon-socket/socket /nix/var/nix/daemon-socket/socket)
      # In a user namespace root is unmapped, so Nix's "auto" store detection
      # rejects the daemon socket and falls back to the (read-only) local store.
      if [[ -z ''${NIX_REMOTE:-} ]]; then
        args+=(--setenv NIX_REMOTE daemon)
      fi
    fi

    # Share download caches so package managers don't refetch everything.
    if (( use_caches )); then
      for p in \
        "$HOME/.cache/uv" \
        "$HOME/.cache/pip" \
        "$HOME/.cache/nix" \
        "$HOME/.cache/pre-commit" \
        "$HOME/.cache/pnpm" \
        "$HOME/.cache/yarn" \
        "$HOME/.cache/go-build" \
        "$HOME/.cache/electron" \
        "$HOME/.cargo/registry" \
        "$HOME/.cargo/git" \
        "$HOME/.npm/_cacache" \
        "$HOME/.local/share/pnpm/store" \
        "$HOME/.local/share/uv/python" \
        "$HOME/.local/share/uv/tools" \
        "$HOME/.rustup" \
        "$HOME/.android" \
        "$HOME/go/pkg/mod" \
        "$HOME/.gradle/caches" \
        "$HOME/.gradle/wrapper" \
        "$HOME/.m2/repository"; do
        if [[ -e $p ]]; then
          args+=(--bind "$p" "$p")
        fi
      done
    fi

    for p in ''${ro_binds[@]+"''${ro_binds[@]}"}; do
      args+=(--ro-bind "$p" "$p")
    done
    for p in ''${rw_binds[@]+"''${rw_binds[@]}"}; do
      args+=(--bind "$p" "$p")
    done

    secret_re='token|secret|passw|api[_-]?key|private[_-]?key|credential|^aws_|^gh_|^github_|^gitlab_|^npm_|^sops_|^vault_|^openai_|^anthropic_|^venice_|^huggingface_|^hf_|^wandb_|^docker_|^ssh_auth_sock$|^gpg_agent_info$|^keychain_'
    allow_re='^(PATH|TERM|LANG|TZ|SHELL|IN_NIX_SHELL|SSL_CERT_FILE|CURL_CA_BUNDLE|NO_PROXY|HTTPS?_PROXY|ALL_PROXY|NIX_|LC_)'

    env_args=()
    shopt -s nocasematch
    while IFS= read -r line; do
      var=''${line%%=*}
      [[ $var =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]] || continue
      [[ -v $var ]] || continue
      if (( clear_env )); then
        [[ $var =~ $allow_re ]] || continue
      elif [[ $var =~ $secret_re ]]; then
        keep=0
        for k in ''${keep_envs[@]+"''${keep_envs[@]}"}; do
          [[ $var == "$k" ]] && keep=1
        done
        (( keep )) || continue
      fi
      env_args+=(--setenv "$var" "''${!var}")
    done < <(env)

    args+=(''${env_args[@]+"''${env_args[@]}"})
    args+=(--setenv HOME "$HOME" --setenv TMPDIR /tmp --setenv XDG_RUNTIME_DIR /tmp/xdg)

    exec bwrap "''${args[@]}" "$@"
  '';
}
