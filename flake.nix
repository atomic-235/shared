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
        lazysql = import ./modules/lazysql.nix;
        opencode = import ./modules/opencode.nix;
        bash = import ./modules/bash.nix;
        yazi = import ./modules/yazi.nix;
        delta = import ./modules/delta.nix;
        packages = import ./modules/packages.nix;
        tmux = import ./modules/tmux.nix;
        termusic = import ./modules/termusic.nix;
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
        opencode = final: prev: {
          opencode = import ./overlays/opencode { pkgs = prev; };
        };
        waybar = final: prev: {
          waybar = import ./overlays/waybar { pkgs = prev; };
        };
      };

      packages = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (system: {
        opencode = import ./overlays/opencode { pkgs = nixpkgs.legacyPackages.${system}; };
        waybar = import ./overlays/waybar { pkgs = nixpkgs.legacyPackages.${system}; };
        default = self.packages.${system}.opencode;
      });

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
