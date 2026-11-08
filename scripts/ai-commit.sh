#!/usr/bin/env bash
set -euo pipefail

GPG_TTY=$(tty)
export GPG_TTY

# Source AI model config if present (XDG-compliant, works in non-interactive shells)
_config="${XDG_CONFIG_HOME:-$HOME/.config}/ai/models"
if [ -f "$_config" ]; then
  # shellcheck disable=SC1090
  . "$_config"
  unset _config
fi

DIFF=$(git diff --cached)
if [ -z "$DIFF" ]; then
    gum style --foreground 1 "No staged changes"
    exit 1
fi

DIFF_FILE=$(mktemp)
git diff --cached > "$DIFF_FILE"

OUT_FILE=$(mktemp)

if [ -n "${AI_MODEL_FAST:-}" ]; then
  MODEL_ARG=(-m "$AI_MODEL_FAST")
else
  MODEL_ARG=()
fi

# Smart proxy detection: if proxy is running on $PROXY_PORT (default 20172), route through it
PROXY_PORT="${PROXY_PORT:-20172}"
if ss -tlnH "sport = :${PROXY_PORT}" 2>/dev/null | grep -q .; then
  export http_proxy="http://127.0.0.1:${PROXY_PORT}"
  export https_proxy="http://127.0.0.1:${PROXY_PORT}"
  export no_proxy="127.0.0.1,localhost,::1"
  export NO_PROXY="127.0.0.1,localhost,::1"
fi

PROMPT='Generate a Conventional Commits message for this diff.
Template:
<type>(<scope>): <summary>
<blank line>
<body explaining why the change was made, wrapped at 72 columns>

Rules: type is one of feat, fix, refactor, perf, docs, test, build, ci, chore, style. Scope is optional. Summary is imperative mood, lower-case, no trailing period, at most 72 characters. Add a body only when the summary alone does not explain the change, and wrap it at 72 columns. Output ONLY the commit message, with no code fences.'

TERM_PROGRAM=Apple_Terminal gum spin --spinner dot --title "Generating..." -- \
  with-secrets ai opencode run --auto "${MODEL_ARG[@]}" --format json "$PROMPT" -f "$DIFF_FILE" >"$OUT_FILE" 2>/dev/null

# Keep the blank line and body: join all text parts, trim trailing spaces and
# surrounding blank lines. Flattening newlines here would merge the body into
# the summary and break the template.
MSG=$(jq -r 'select(.type == "text") | .part.text' "$OUT_FILE" |
  sed 's/[[:space:]]*$//' |
  awk 'NF { n = NR } { l[NR] = $0 } END { for (i = 1; i <= n; i++) print l[i] }')

rm "$DIFF_FILE" "$OUT_FILE"

if [ "${1:-}" = "--commit" ] || [ "${1:-}" = "-c" ]; then
    gum style --foreground 2 "$MSG"
    git commit -m "$MSG"
else
    echo "$MSG"
fi
