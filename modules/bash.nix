{ lib, pkgs, config, ... }:

let
  cfg = config.programs.bash.aiModels;
in
{
  options.programs.bash.aiModels = lib.mkOption {
    type = with lib.types; attrsOf str;
    default = { };
    description = ''
      AI model tiers (fast, default, etc.) mapped to model IDs.
      Creates AI_MODEL_<TIER> env vars and ~/.config/ai/models sourceable file.
    '';
  };

  config = {
    home.sessionVariables = lib.mkMerge [
      {
        EDITOR = "nvim";
        VISUAL = "nvim";
        LIBSQLITE = "${pkgs.sqlite.out}/lib/libsqlite3.so";
      }
      (lib.mapAttrs' (tier: model: lib.nameValuePair "AI_MODEL_${lib.toUpper tier}" model) cfg)
    ];

    # AI model tiers — sourceable XDG config file for non-interactive shells
    # (lazygit tmux popup).
    xdg.configFile."ai/models" = lib.mkIf (cfg != { }) {
      text = lib.concatStringsSep "\n" (
        lib.mapAttrsToList (tier: model: "AI_MODEL_${lib.toUpper tier}=\"${model}\"") cfg
      ) + "\n";
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
      # Auto-enter nix-user-chroot for rootless nix (portable environment)
      # Only triggers if nix-user-chroot binary exists and not already inside chroot
      if [ -z "$IN_NIX_USER_CHROOT" ] && [ -x "$HOME/.local/bin/nix-user-chroot" ] && [ -d "$HOME/.nix/store" ]; then
        export IN_NIX_USER_CHROOT=1
        exec "$HOME/.local/bin/nix-user-chroot" "$HOME/.nix" bash --noprofile --norc -c '
          . "$HOME/.nix-profile/etc/profile.d/nix.sh"
          [ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"
          exec bash -i
        '
      fi

      # Source nix profile if inside nix-user-chroot (rootless nix)
      if [ -n "$IN_NIX_USER_CHROOT" ] && [ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
        . "$HOME/.nix-profile/etc/profile.d/nix.sh"
      fi

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
    '';
    };
  };
}
