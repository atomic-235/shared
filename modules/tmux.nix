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

      # tmux 3.8 themes: force the dark variant and remap its palette to
      # Tokyo Night, so every themed style (borders, copy-mode, popups,
      # clock, scrollbars) uses Tokyo Night instead of the terminal palette.
      set -s theme dark
      set -s dark-theme-black "#1a1b26"
      set -s dark-theme-white "#c0caf5"
      set -s dark-theme-light-grey "#565f89"
      set -s dark-theme-dark-grey "#292e42"
      set -s dark-theme-green "#9ece6a"
      set -s dark-theme-yellow "#e0af68"
      set -s dark-theme-red "#f7768e"
      set -s dark-theme-blue "#7aa2f7"
      set -s dark-theme-cyan "#7dcfff"
      set -s dark-theme-magenta "#bb9af7"

      # Report Ctrl+Tab / Ctrl+Shift+Tab as distinct keys instead of
      # collapsing them to Tab, so opencode's session.tab.next/previous
      # (bound to ctrl+tab / ctrl+shift+tab) can fire.
      set -g extended-keys always
      set -g extended-keys-format csi-u

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
      # Yank: pipe to system clipboard if available (WSL, Wayland), else tmux buffer
      bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "if command -v clip.exe >/dev/null 2>&1; then clip.exe; elif command -v wl-copy >/dev/null 2>&1 && [ -n \"$WAYLAND_DISPLAY\" ]; then wl-copy; fi"
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

      # Project sessionizer
      bind-key -r P display-popup -E "case \$TMUX in *share*) tmux-sessionizer ~/projects/work/ ;; *) tmux-sessionizer ~/projects/personal/ ;; esac"

      # Popup border style (Tokyo Night)
      set -g popup-border-style "fg=#7aa2f7"

      # Popup background follows the theme (themeblack = #1a1b26), so apps
      # run in display-popup (fzf, sessionizer) don't sit on themedarkgrey.
      set -g popup-style "bg=themeblack,fg=themewhite"

      # Session/window tree (choose-tree): same background as the terminal
      # instead of the themedarkgrey tile.
      set -g tree-mode-border-style "bg=themeblack,fg=themelightgrey"

      # Source project .tmux manually (prefix T). Never auto-source: a
      # foreign repo's .tmux would execute unsandboxed code server-side.
      bind-key T run-shell 'tmux source-file "#{pane_current_path}/.tmux"'
    '';
  };
}
