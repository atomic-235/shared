{
  description = "Shared home-manager modules for portable terminal environments";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
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
      };

      # Combined overlay for convenience
      defaultOverlay = final: prev: {
        lazygit = import ./overlays/lazygit { pkgs = prev; };
        tmux = import ./overlays/tmux { pkgs = prev; };
        with-secrets = import ./scripts/with-secrets.nix { pkgs = prev; };
      };

      # For consumers that want to evaluate modules directly
      lib = {
        forAllSystems = forAllSystems;
      };
    };
}
