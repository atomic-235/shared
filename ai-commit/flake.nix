{
  description = "AI-powered commit message generator using pydantic-ai";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
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

  outputs = { self, nixpkgs, uv2nix, pyproject-nix, pyproject-build-systems }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      workspace = uv2nix.lib.workspace.loadWorkspace { workspaceRoot = ./.; };
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

      # ai-commit binary — wraps the Python entry point with git + iproute2 in PATH
      aiCommit = pkgs.writeShellApplication {
        name = "ai-commit";
        runtimeInputs = [ pkgs.git pkgs.iproute2 ];
        text = ''
          exec ${venv}/bin/ai-commit "$@"
        '';
      };
    in
    {
      packages.${system} = {
        default = aiCommit;
        ai-commit = aiCommit;
        venv = venv;
      };

      # Export for use by shared flake
      inherit aiCommit;
    };
}
