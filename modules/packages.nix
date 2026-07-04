{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Editors
    neovim
    btop

    # CLI tools
    git
    gh
    eza
    bat
    fd
    ripgrep
    jq
    curl
    wget
    gum

    # AI coding agent
    opencode

    # Build tools (needed by nvim-treesitter to compile parsers)
    gcc
    tree-sitter

    # Scripts
    (pkgs.writeShellApplication {
      name = "tmux-sessionizer";
      runtimeInputs = [ pkgs.fzf pkgs.tmux ];
      text = builtins.readFile ../scripts/tmux-sessionizer.sh;
    })
    (pkgs.writeShellApplication {
      name = "ai-commit";
      runtimeInputs = [ pkgs.gum pkgs.jq ];
      text = builtins.readFile ../scripts/ai-commit.sh;
    })

    # Tools used by shared modules
    # delta installed via programs.delta.enable (delta module)
    # fzf, zoxide, direnv, starship, lazygit, yazi installed via programs.*.enable
    # sops, age installed via with-secrets runtimeInputs
  ];
}
