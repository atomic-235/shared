#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  qr-secure.sh            prompt for secret (hidden input, no echo)
  qr-secure.sh FILE       read secret from FILE
  printf '%s' SECRET | qr-secure.sh
  qr-secure.sh -c         clear terminal after rendering

Secret never appears in shell history or process args.
EOF
}

clear_after=0
file_arg=""

while [ $# -gt 0 ]; do
  case "$1" in
    -c|--clear) clear_after=1 ;;
    -h|--help) usage; exit 0 ;;
    -*) echo "unknown flag: $1" >&2; usage >&2; exit 2 ;;
    *) file_arg="$1" ;;
  esac
  shift
done

secret=""
cleanup() {
  secret=""
  unset secret
}
trap cleanup EXIT

if [ -n "$file_arg" ]; then
  [ -r "$file_arg" ] || { echo "cannot read: $file_arg" >&2; exit 1; }
  secret="$(cat "$file_arg")"
elif [ ! -t 0 ]; then
  secret="$(cat)"
else
  printf 'Secret: '
  IFS= read -rs secret || { echo; exit 1; }
  echo
  printf 'Confirm: '
  IFS= read -rs confirm || { echo; exit 1; }
  echo
  [ "$secret" = "$confirm" ] || { echo "mismatch" >&2; exit 1; }
  unset confirm
fi

[ -n "$secret" ] || { echo "empty input" >&2; exit 1; }

printf '%s' "$secret" | cliqr

if [ "$clear_after" -eq 1 ]; then
  printf '\nPress Enter to clear screen...'
  IFS= read -r _
  clear
fi
