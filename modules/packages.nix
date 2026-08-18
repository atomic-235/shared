{ pkgs, ... }:

let
  tree-sitter-clingo = pkgs.tree-sitter.buildGrammar {
    language = "clingo";
    version = "2025-07-04";
    src = pkgs.fetchFromGitHub {
      owner = "potassco";
      repo = "tree-sitter-clingo";
      rev = "58e062c1c6c2ac0bad54fee054573c5a9e6dd759";
      hash = "sha256-rygMKByGqO0P0ftNezCJxWkZJVIsZv9j91avaUWQ3Sk=";
    };
  };
in
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
    lz4

    # AI coding agent
    opencode

    # Typesetting
    typst
    tinymist
    texlab
    neovim-remote

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
    yaml-language-server
    texlab
    nixfmt
    ruff
    python313Packages.debugpy
    shfmt
    stylua
    prettier
    lean4
    nim
    nimlangserver

    # Logic programming
    clingo

    # SMT solving
    python312Packages.z3-solver

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

  # tree-sitter-clingo parser + queries for neovim
  # Placed in stdpath("data")/site — stable path, HM-managed symlinks to nix store
  xdg.dataFile = {
    "nvim/site/parser/clingo.so".source = "${tree-sitter-clingo}/parser";
    "nvim/site/queries/clingo/highlights.scm".source = "${tree-sitter-clingo}/queries/highlights.scm";
    "nvim/site/queries/clingo/injections.scm".source = "${tree-sitter-clingo}/queries/injections.scm";
    "nvim/site/queries/clingo/indents.scm".source = "${tree-sitter-clingo}/queries/indents.scm";
    "nvim/site/queries/clingo/textobjects.scm".source = "${tree-sitter-clingo}/queries/textobjects.scm";
  };
}
