{ pkgs, ... }:

{
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    LIBSQLITE = "${pkgs.sqlite.out}/lib/libsqlite3.so";
  };

  programs.bash = {
    enable = true;

    historyControl = [
      "ignoredups"
      "erasedups"
    ];
    historyIgnore = [
      "*BEGIN*PRIVATE*KEY*"
      "*END*PRIVATE*KEY*"
      "*secret*=*"
      "*SECRET*=*"
      "*password*=*"
      "*PASSWORD*=*"
      "*token*=*"
      "*TOKEN*=*"
      "*api_key*=*"
      "*API_KEY*=*"
    ];

    shellOptions = [
      "histappend"
      "checkwinsize"
      "extglob"
      "globstar"
      "huponexit"
    ];

    sessionVariables = {
      PATH = "$HOME/.local/bin:$PATH";
      SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/ssh-agent.socket";
      GPG_TTY = "$(tty)";
    };

    shellAliases = {
      ls = "eza -lh --group-directories-first --icons=always";
    };

    initExtra = ''
      # Vi mode
      set -o vi

      # Source custom scripts from .bashrc.d/
      if [[ -d ~/.bashrc.d ]]; then
        for script in ~/.bashrc.d/*.sh; do
          [[ -f "$script" ]] && source "$script"
        done
      fi

      # tmux functions - create or attach to session (defaults to "tmux")
      tm() {
        local name="''${1:-tmux}"
        tmux new-session -A -s "$name" 2>/dev/null || tmux attach -t "$name"
      }
      tms() {
        local name="''${1:-tmux}"
        tmux -L share new-session -A -s "$name" 2>/dev/null || tmux -L share attach -t "$name"
      }

      # tmux-sessionizer wrapper — sets AI command based on session context
      tmux-sessionizer() {
        if [[ "$TMUX" == */share,* ]]; then
          SESSIONIZER_AI_CMD="work-opencode" command tmux-sessionizer "$@"
        else
          SESSIONIZER_AI_CMD="opencode" command tmux-sessionizer "$@"
        fi
      }
    '';
  };
}
