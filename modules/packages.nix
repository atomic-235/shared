{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Editors
    neovim
    btop
    moor
    lnav

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
    dust
    htop
    stow
    unzip
    zip
    gnused
    gawk
    procps
    tldr
    figlet
    toilet
    fastfetch

    # AI coding agent
    opencode

    # AI commit message generator (pydantic-ai, built via uv2nix overlay)
    ai-commit

    # Build tools (needed by nvim-treesitter to compile parsers)
    gcc
    tree-sitter

    # Development
    python3
    bun
    pkg-config
    openssl
    opentimestamps-client

    # Secret management
    gnupg
    git-crypt
    sops
    age
    age-plugin-yubikey

    # Backup
    restic

    # Encryption & cloud sync
    cryptomator-cli
    rclone

    # Containers
    podman-compose

    # LSP servers and formatters (for neovim)
    basedpyright
    vscode-langservers-extracted
    lua-language-server
    nixd
    nixfmt
    ruff
    python313Packages.debugpy
    shfmt
    stylua
    prettier

    # nvim dependencies
    sqlite
    sqlite.out
    imagemagick
    librsvg
    graphviz

    # Scripts
    (pkgs.writeShellApplication {
      name = "tmux-sessionizer";
      runtimeInputs = [ pkgs.fzf pkgs.tmux ];
      text = builtins.readFile ../scripts/tmux-sessionizer.sh;
    })

    # Tools used by shared modules
    # delta installed via programs.delta.enable (delta module)
    # fzf, zoxide, direnv, starship, lazygit, yazi installed via programs.*.enable
  ];
}
