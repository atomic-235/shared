{
  description = "Shared home-manager modules for portable terminal environments";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    swls.url = "github:SemanticWebLanguageServer/swls/b5c3a82f8cf84992f103c9e8b8b01a5303d6b92d";

    venice-mcp-server = {
      url = "github:veniceai/venice-mcp-server";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      swls,
      venice-mcp-server,
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
        lazygit = final: prev: {
          lazygit = import ./overlays/lazygit { pkgs = prev; };
        };
        tmux = final: prev: {
          tmux = import ./overlays/tmux { pkgs = prev; };
        };
        with-secrets = final: prev: {
          with-secrets = import ./scripts/with-secrets.nix { pkgs = prev; };
        };
        with-jail = final: prev: {
          with-jail = import ./scripts/with-jail.nix { pkgs = prev; };
        };
        opencode = final: prev: {
          opencode = import ./overlays/opencode { pkgs = prev; };
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
        venice-mcp-server = final: prev: {
          venice-mcp-server = import ./overlays/venice-mcp-server {
            inherit (prev) lib buildNpmPackage makeWrapper;
            src = venice-mcp-server;
          };
        };
        swls = final: prev: {
          swls = swls.packages.${prev.stdenv.hostPlatform.system}.swls;
        };
        default = self.defaultOverlay;
      };

      # Combined overlay for consumers: every package cache-built by shared.
      defaultOverlay = nixpkgs.lib.composeManyExtensions [
        self.overlays.lazygit
        self.overlays.tmux
        self.overlays.with-secrets
        self.overlays.with-jail
        self.overlays.opencode
        self.overlays.waybar
        self.overlays.xdg-desktop-portal
        self.overlays.wl-kbptr
        self.overlays.venice-mcp-server
        self.overlays.swls
      ];

      packages = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          inherit (pkgs)
            opencode
            waybar
            lazygit
            tmux
            swls
            xdg-desktop-portal
            wl-kbptr
            venice-mcp-server
            ;
          default = self.packages.${system}.opencode;
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
