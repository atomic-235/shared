{ pkgs, ... }:

let
  # Fix opencode segfault on WSL2 — nixpkgs bug: glibc 2.42/2.40 mismatch
  # opencode derivation uses stdenvNoCC with no patchelf.
  # Build smoke test segfaults before postFixup runs — must strip it.
  # See: https://github.com/anomalyco/opencode/issues/26846
  opencode-fixed = pkgs.opencode.overrideAttrs (old: {
    # Strip smoke test from build.ts — segfaults on WSL2 (glibc mismatch)
    postPatch = (old.postPatch or "") + ''
      sed -i '/Smoke test: only run/,/process\.exit(1)/c\    // smoke test removed for cross-platform compat' \
        packages/opencode/script/build.ts
    '';
    # Skip versionCheckHook — same segfault
    doInstallCheck = false;
    # Patchelf binary to use consistent glibc
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.patchelf ];
    postFixup = (old.postFixup or "") + ''
      ${pkgs.patchelf}/bin/patchelf --set-rpath ${pkgs.glibc}/lib $out/bin/opencode
      ${pkgs.patchelf}/bin/patchelf --set-interpreter ${pkgs.glibc}/lib64/ld-linux-x86-64.so.2 $out/bin/opencode
    '';
  });
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

    # AI coding agent
    opencode-fixed

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

    # Tools used by shared modules
    # delta installed via programs.delta.enable (delta module)
    # fzf, zoxide, direnv, starship, lazygit, yazi installed via programs.*.enable
  ];
}
