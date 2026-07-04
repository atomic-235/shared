#!/usr/bin/env bash
set -euo pipefail

search_dir="${1:-~/projects}"
search_dir="${search_dir/#\~/$HOME}"
search_dir="${search_dir%/}"
# Build list: depth-1 dirs + submodule dirs from projects with .gitmodules
mapfile -t dirs < <(find "$search_dir" -mindepth 1 -maxdepth 1 -type d)
entries=()
for d in "${dirs[@]}"; do
    entries+=("$d")
    if [[ -f "$d/.gitmodules" ]]; then
        while IFS= read -r sm; do
            [[ -d "$d/$sm" ]] && entries+=("$d/$sm")
        done < <(awk '/path = /{print $3}' "$d/.gitmodules")
    fi
done
selected=$(printf '%s\n' "${entries[@]}" | fzf --print-query --expect=ctrl-n)
query=$(echo "$selected" | head -1)
key=$(echo "$selected" | sed -n '2p')
selected=$(echo "$selected" | sed -n '3p')

if [[ -z $selected ]] && [[ -z $query ]]; then
    exit 0
fi

if [[ $key == "ctrl-n" ]] || { [[ -z $selected ]] && [[ -n $query ]]; }; then
    selected="$search_dir/$query"
    mkdir -p "$selected"
fi

selected_name=$(basename "$selected" | tr . _)
tmux_running=$(pgrep tmux)

if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
    tmux new-session -s "$selected_name" -c "$selected"
    exit 0
fi

if ! tmux has-session -t="$selected_name" 2> /dev/null; then
    tmux new-session -ds "$selected_name" -n "bash" -c "$selected"

    tmux new-window -t "$selected_name" -n "nvim" -c "$selected"
    if [[ -f "$selected/.envrc" ]]; then
        tmux send-keys -t "$selected_name:nvim" "direnv exec . nvim . || nvim ." C-m
    elif [[ -d "$selected/.venv" ]]; then
        tmux send-keys -t "$selected_name:nvim" "source $selected/.venv/bin/activate && nvim ." C-m
    else
        tmux send-keys -t "$selected_name:nvim" "nvim ." C-m
    fi

    tmux new-window -t "$selected_name" -n "ai" -c "$selected"
    if [[ "$TMUX" == */share,* ]]; then
      ai_cmd="${SESSIONIZER_AI_CMD_WORK:-work-opencode}"
    else
      ai_cmd="${SESSIONIZER_AI_CMD:-opencode}"
    fi
    tmux send-keys -t "$selected_name:ai" "$ai_cmd" C-m

    tmux select-window -t "$selected_name:bash"
    # Source .tmux file if it exists in the selected directory
    if [[ -f "$selected/.tmux" ]]; then
        tmux set-environment -t "$selected_name" PROJECT_ROOT "$selected"
        tmux source-file "$selected/.tmux"
    fi
fi

tmux switch-client -t "$selected_name"
