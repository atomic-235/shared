{
  description = "Shared home-manager modules for portable terminal environments";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    uv2nix = {
      url = "github:pyproject-nix/uv2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pyproject-nix = {
      url = "github:pyproject-nix/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pyproject-build-systems = {
      url = "github:pyproject-nix/build-system-pkgs";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, uv2nix, pyproject-nix, pyproject-build-systems, ... }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # Build ai-commit Python package via uv2nix
      aiCommitFor = system:
        let
          pkgs = import nixpkgs { inherit system; };
          workspace = uv2nix.lib.workspace.loadWorkspace { workspaceRoot = ./ai-commit; };
          overlay = workspace.mkPyprojectOverlay { sourcePreference = "wheel"; };
          python = pkgs.python313;
          pythonSet =
            (pkgs.callPackage pyproject-nix.build.packages { inherit python; })
            .overrideScope (pkgs.lib.composeManyExtensions [
              pyproject-build-systems.overlays.default
              overlay
            ]);
          venv = pythonSet.mkVirtualEnv "ai-commit-env" {
            ai-commit = [];
          };
        in
        pkgs.writeShellApplication {
          name = "ai-commit";
          runtimeInputs = [ pkgs.git pkgs.iproute2 pkgs.gum ];
          text = ''
            GPG_TTY="$(tty)"
            export GPG_TTY

            # Smart proxy detection: if proxy is running on port 12334, route through it
            if ss -tlnH 'sport = :12334' 2>/dev/null | grep -q .; then
              export http_proxy=http://127.0.0.1:12334
              export https_proxy=http://127.0.0.1:12334
            fi

            gum confirm "Touch YubiKey to decrypt?" || exit 1

            gum spin --spinner dot --title "Generating..." -- \
              exec ${venv}/bin/ai-commit "$@"
          '';
        };
    in
    {
      homeManagerModules = {
        btop = import ./modules/btop.nix;
        starship = import ./modules/starship.nix;
        shell-tools = import ./modules/shell-tools.nix;
        neovim = import ./modules/neovim.nix;
        lazygit = import ./modules/lazygit.nix;
        opencode = import ./modules/opencode.nix;
        bash = import ./modules/bash.nix;
        yazi = import ./modules/yazi.nix;
        delta = import ./modules/delta.nix;
        packages = import ./modules/packages.nix;
        tmux = import ./modules/tmux.nix;
      };

      overlays = {
        lazygit = final: prev: {
          lazygit = import ./overlays/lazygit { pkgs = prev; };
        };
        tmux = final: prev: {
          tmux = import ./overlays/tmux { pkgs = prev; };
        };
        with-secrets = final: prev: {
          with-secrets = import ./scripts/with-secrets.nix { pkgs = prev; };
        };
        ai-commit = final: prev: {
          ai-commit = aiCommitFor final.system;
        };
      };

      # Combined overlay for convenience
      defaultOverlay = final: prev: {
        lazygit = import ./overlays/lazygit { pkgs = prev; };
        tmux = import ./overlays/tmux { pkgs = prev; };
        with-secrets = import ./scripts/with-secrets.nix { pkgs = prev; };
        ai-commit = aiCommitFor prev.stdenv.system;
      };

      # For consumers that want to evaluate modules directly
      lib = {
        forAllSystems = forAllSystems;
      };
    };
}
