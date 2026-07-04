{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    prefix = "C-a";
    terminal = "tmux-256color";
    escapeTime = 0;

    plugins = with pkgs.tmuxPlugins; [
      {
        plugin = tokyo-night-tmux;
        extraConfig = ''
          set -g @tokyo-night-tmux_theme "night"
        '';
      }
    ];

    extraConfig = ''
      # Enable true color support
      set -ag terminal-overrides ",xterm-256color:RGB"
      set -ag terminal-overrides ",*-ghostty:Tc"

      # Enable image passthrough for yazi (Kitty graphics protocol)
      set -g allow-passthrough on
      set -ga update-environment TERM
      set -ga update-environment TERM_PROGRAM

      # Vi mode for copy mode
      set-window-option -g mode-keys vi

      # Vi-style copy mode bindings
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi V send-keys -X select-line
      bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
      bind-key -T copy-mode-vi Escape send-keys -X cancel

      # Disable status bar
      set -g status off

      # Fuzzy window selection (current session only)
      bind-key "'" display-popup -E "tmux list-windows -F '#I:#W' | fzf --reverse | cut -d: -f1 | xargs -r tmux select-window -t"

      # Window/session selector (prefix + w)
      # Selector colors (Tokyo Night)
      set -g mode-style "bg=#283457,fg=#c0caf5"
      bind-key w choose-tree -Zw -K "" -F '#{?window_format,#[fg=#7aa2f7]#{?#{==:#{window_name},nvim},󰈮 ,#{?#{==:#{window_name},ai},󰚩 ,#{?#{==:#{window_name},bash}, ,#{?#{==:#{window_name},backend},󰒍 ,#{?#{==:#{window_name},frontend},󰖟 ,#{?#{==:#{window_name},deploy},󰣪 ,#{?#{==:#{window_name},zsh}, ,#{?#{==:#{pane_current_command},nvim},󰈮 ,#{?#{==:#{pane_current_command},python},󰌠 ,#{?#{==:#{pane_current_command},node},󰎙 , }}}}}}}}}}#[fg=#c0caf5]#{window_name},#[fg=#7aa2f7]#{?session_attached, #[fg=#9ece6a](attached),}}'

      # Switch to last active session
      bind-key L switch-client -l

      # Quick window switching
      bind-key O select-window -t ai
      bind-key N select-window -t nvim
      bind-key S select-window -t bash
      bind-key B select-window -t backend
      bind-key F select-window -t frontend
      bind-key D select-window -t deploy

      # Popup border style (Tokyo Night)
      set -g popup-border-style "fg=#7aa2f7"

      # Auto-source .tmux file if it exists in current directory
      if-shell "[ -f .tmux ]" "source-file .tmux"
    '';
  };
}
