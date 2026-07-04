{ pkgs }:

pkgs.writeShellApplication {
  name = "with-secrets";
  runtimeInputs = [ pkgs.sops ];
  text = ''
    set -euo pipefail

    SECRETS_DIR="''${SECRETS_DIR:?SECRETS_DIR env var not set. Set it to your secrets directory.}"

    if [[ $# -lt 2 ]]; then
      echo "Usage: with-secrets <group> <command...>" >&2
      echo "Example: with-secrets ai opencode run ..." >&2
      exit 1
    fi

    GROUP="$1"
    shift
    FILE="$SECRETS_DIR/$GROUP.yaml"

    if [[ ! -f "$FILE" ]]; then
      echo "Error: Secrets file not found: $FILE" >&2
      exit 1
    fi

    # exec-env expects a single command string, so we quote arguments correctly
    # Use printf '%q ' to escape arguments for shell execution by sops
    # --same-process: exec the command directly instead of spawning a child
    # This ensures signals (SIGHUP, SIGTERM) propagate correctly to the child
    CMD=$(printf '%q ' "$@")
    echo "[t=$(date +%s%3N)] sops exec-env starting" >&2
    exec sops exec-env --same-process "$FILE" "$CMD"
  '';
}
