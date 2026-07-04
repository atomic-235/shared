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
      };

      # For consumers that want to evaluate modules directly
      lib = {
        forAllSystems = forAllSystems;
      };
    };
}
