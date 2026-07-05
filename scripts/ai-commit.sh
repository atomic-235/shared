#!/usr/bin/env bash
set -euo pipefail

GPG_TTY=$(tty)
export GPG_TTY

# Source config file if present (XDG-compliant, no hardcoded values)
_config="${XDG_CONFIG_HOME:-$HOME/.config}/ai-commit/config"
[ -f "$_config" ] && source "$_config" && unset _config

DIFF=$(git diff --cached)
if [ -z "$DIFF" ]; then
    gum style --foreground 1 "No staged changes"
    exit 1
fi

DIFF_FILE=$(mktemp)
git diff --cached > "$DIFF_FILE"

gum confirm "Touch YubiKey to decrypt?" || exit 1

OUT_FILE=$(mktemp)

if [ -n "${AI_COMMIT_MODEL:-}" ]; then
  MODEL_ARG=(-m "$AI_COMMIT_MODEL")
  gum style --foreground 6 "Using model: $AI_COMMIT_MODEL"
else
  MODEL_ARG=()
  gum style --foreground 3 "AI_COMMIT_MODEL not set — using opencode default"
fi

# Smart proxy detection: if proxy is running on port 12334, route through it
if ss -tlnH 'sport = :12334' 2>/dev/null | grep -q .; then
  export http_proxy=http://127.0.0.1:12334
  export https_proxy=http://127.0.0.1:12334
fi

gum spin --spinner dot --title "Generating..." -- \
  bash -c "with-secrets ai opencode run ${MODEL_ARG[*]:-} --format json 'Generate a single concise conventional commit message for this diff. Output ONLY the commit message, nothing else:' -f '$DIFF_FILE' 2>/dev/null > '$OUT_FILE'"

MSG=$(cat "$OUT_FILE" | grep '"type":"text"' | jq -r '.part.text' | tr '\n' ' ' | sed 's/[[:space:]]*$//')

rm "$DIFF_FILE" "$OUT_FILE"

if [ "${1:-}" = "--commit" ] || [ "${1:-}" = "-c" ]; then
    gum style --foreground 2 "$MSG"
    git commit -m "$MSG"
else
    echo "$MSG"
fi
