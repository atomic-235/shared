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

  # openCypher grammar — highlights .cypher files and Cypher injected into
  # Python strings (see nvim after/queries/python/injections.scm).
  tree-sitter-cypher = pkgs.tree-sitter.buildGrammar {
    language = "cypher";
    version = "2026-10-15";
    src = pkgs.fetchFromGitHub {
      owner = "simplificare-org";
      repo = "tree-sitter-cypher";
      rev = "775717a2de6ca76a5a75e8076b411dbc1ae4c281";
      hash = "sha256-kO6pryiKKCNxg7Gx1neUf4Zw+i7J6OsJkCTi0o9MZZw=";
    };
  };

  # Nickel grammar — highlights .ncl files.
  tree-sitter-nickel = pkgs.tree-sitter.buildGrammar {
    language = "nickel";
    version = "2026-07-31";
    src = pkgs.fetchFromGitHub {
      owner = "nickel-lang";
      repo = "tree-sitter-nickel";
      rev = "fd65591d3c7812b0e3e733506f3f08a354a38ea6";
      hash = "sha256-882e4ot/nEaRZ+YvVxn8IIfVlhmD44AnWgEhp5xfN6U=";
    };
  };

  # Prebuilt release binary (the Go module proxy fetch fails on some networks).
  gittop = pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "gittop";
    version = "0.4.0";
    src = pkgs.fetchurl {
      url = "https://github.com/hjr265/gittop/releases/download/v${finalAttrs.version}/gittop_${finalAttrs.version}_linux_amd64.tar.gz";
      hash = "sha256-FhGZMxgXh4mGVzEPEYqL00Z7utJ3pb8WlN2jXR5eKDs=";
    };
    sourceRoot = ".";
    installPhase = ''
      mkdir -p $out/bin
      install -m755 gittop $out/bin/gittop
    '';
    meta.mainProgram = "gittop";
  });
in
{
  home.packages = with pkgs; [
    # Editors
    neovim
    btop
    lnav

    # CLI tools
    git
    gh
    gittop
    git-quick-stats
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

    # Media
    termusic

    # File sharing
    cliqr

    # Containers
    podman-compose

    # LSP servers and formatters (for neovim)
    basedpyright
    vscode-langservers-extracted
    lua-language-server
    nixd
    yaml-language-server
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
    (pkgs.writers.writePython3Bin "tmux-sessionizer" { } (
      builtins.readFile ../scripts/tmux-sessionizer.py
    ))
    (pkgs.writers.writePython3Bin "tmux-stats" {
      flakeIgnore = [ "E203" ];
    } (builtins.readFile ../scripts/tmux-stats.py))
    (pkgs.writeShellApplication {
      name = "ai-commit";
      runtimeInputs = [
        pkgs.gum
        pkgs.jq
        pkgs.git
        pkgs.iproute2
      ];
      text = builtins.readFile ../scripts/ai-commit.sh;
    })
    (pkgs.writeShellApplication {
      name = "qr-secure";
      runtimeInputs = [ pkgs.cliqr ];
      text = builtins.readFile ../scripts/qr-secure.sh;
    })
    (pkgs.writeShellApplication {
      name = "gittop-all";
      runtimeInputs = [
        pkgs.git
        pkgs.python3
        gittop
      ];
      text = ''
        exec python3 ${../scripts/gittop_all.py} "$@"
      '';
    })

    # with-secrets — sops exec-env wrapper for decrypting secrets at runtime
    (import ../scripts/with-secrets.nix { inherit pkgs; })
  ];

  # tree-sitter-clingo + tree-sitter-cypher parsers for neovim
  # Placed in stdpath("data")/site — stable path, HM-managed symlinks to nix store
  # (cypher highlights live in the nvim config repo: queries/cypher/highlights.scm)
  xdg.dataFile = {
    "nvim/site/parser/clingo.so".source = "${tree-sitter-clingo}/parser";
    "nvim/site/queries/clingo/highlights.scm".source = "${tree-sitter-clingo}/queries/highlights.scm";
    "nvim/site/queries/clingo/injections.scm".source = "${tree-sitter-clingo}/queries/injections.scm";
    "nvim/site/queries/clingo/indents.scm".source = "${tree-sitter-clingo}/queries/indents.scm";
    "nvim/site/queries/clingo/textobjects.scm".source = "${tree-sitter-clingo}/queries/textobjects.scm";
    "nvim/site/parser/cypher.so".source = "${tree-sitter-cypher}/parser";
    "nvim/site/parser/nickel.so".source = "${tree-sitter-nickel}/parser";
    "nvim/site/queries/nickel/highlights.scm".source = "${tree-sitter-nickel}/queries/highlights.scm";
    "nvim/site/queries/nickel/injections.scm".source = "${tree-sitter-nickel}/queries/injections.scm";
  };
}
