{
  description = "Shared home-manager modules for portable terminal environments";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Release flakes: each upstream version is built and published by its own
    # CI, consumed here as a store-path fetch.
    opencode-flake = {
      url = "github:atomic-235/opencode-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    venice-mcp-flake = {
      url = "github:atomic-235/venice-mcp-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    swls-flake = {
      url = "github:atomic-235/swls-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tmux-flake = {
      url = "github:atomic-235/tmux-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lazygit-flake = {
      url = "github:atomic-235/lazygit-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      opencode-flake,
      venice-mcp-flake,
      swls-flake,
      tmux-flake,
      lazygit-flake,
      ...
    }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
        };
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
        with-secrets = final: prev: {
          with-secrets = import ./scripts/with-secrets.nix { pkgs = prev; };
        };
        with-jail = final: prev: {
          with-jail = import ./scripts/with-jail.nix { pkgs = prev; };
        };
        waybar = final: prev: {
          waybar = import ./overlays/waybar { pkgs = prev; };
        };
        xdg-desktop-portal = final: prev: {
          xdg-desktop-portal = import ./overlays/xdg-desktop-portal { pkgs = prev; };
        };
        wl-kbptr = final: prev: {
          wl-kbptr = import ./overlays/wl-kbptr { pkgs = prev; };
        };
        default = self.defaultOverlay;
      };

      # Combined overlay for consumers: every package cache-built by shared.
      defaultOverlay = nixpkgs.lib.composeManyExtensions [
        self.overlays.with-secrets
        self.overlays.with-jail
        self.overlays.waybar
        self.overlays.xdg-desktop-portal
        self.overlays.wl-kbptr
        opencode-flake.overlays.default
        venice-mcp-flake.overlays.default
        swls-flake.overlays.default
        tmux-flake.overlays.default
        lazygit-flake.overlays.default
      ];

      packages = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          inherit (pkgs)
            waybar
            xdg-desktop-portal
            wl-kbptr
            ;
          default = self.packages.${system}.waybar;
        }
      );

      checks = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (
        system: builtins.removeAttrs self.packages.${system} [ "default" ]
      );

      # For consumers that want to evaluate modules directly
      lib = {
        forAllSystems = forAllSystems;
      };
    };
}
