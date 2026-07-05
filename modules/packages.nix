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
    (pkgs.writeShellApplication {
      name = "ai-commit";
      runtimeInputs = [ pkgs.gum pkgs.jq pkgs.git pkgs.iproute2 ];
      text = builtins.readFile ../scripts/ai-commit.sh;
    })

    # with-secrets — sops exec-env wrapper for decrypting secrets at runtime
    (import ../scripts/with-secrets.nix { inherit pkgs; })
  ];
}
