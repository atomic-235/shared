{ pkgs }:

let
  data = builtins.fromJSON (builtins.readFile ./version.json);
  system = pkgs.stdenv.hostPlatform.system;

  packageName =
    {
      x86_64-linux = "cli-linux-x64";
      aarch64-linux = "cli-linux-arm64";
    }
    .${system} or (throw "opencode: unsupported system ${system}");

  # The npm CLI embeds this daemon inside its Bun binary. That embedded copy is a
  # generic dynamically linked ELF, which NixOS refuses to execute (stub-ld), so
  # persistent terminals fail with "Unable to load terminal". Build the daemon as
  # its own patched package and point opencode at it via OPENCODE_PTY_BIN.
  ptyPackageName =
    {
      x86_64-linux = "pty-linux-x64-gnu";
      aarch64-linux = "pty-linux-arm64-gnu";
    }
    .${system} or (throw "opencode-pty: unsupported system ${system}");

  opencode-pty = pkgs.stdenv.mkDerivation {
    pname = "opencode-pty";
    version = data.pty.version;

    src = pkgs.fetchurl {
      url = "https://registry.npmjs.org/@opencode-ai/${ptyPackageName}/-/${ptyPackageName}-${data.pty.version}.tgz";
      hash = data.pty.packages.${system};
    };

    nativeBuildInputs = [ pkgs.autoPatchelfHook ];
    buildInputs = [ pkgs.stdenv.cc.cc.lib ];

    dontConfigure = true;
    dontBuild = true;
    dontStrip = true;

    installPhase = ''
      runHook preInstall
      install -Dm755 bin/opencode-pty $out/bin/opencode-pty
      runHook postInstall
    '';

    meta = with pkgs.lib; {
      description = "Persistent PTY daemon for OpenCode";
      homepage = "https://github.com/anomalyco/opencode-pty";
      license = licenses.mit;
      platforms = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      mainProgram = "opencode-pty";
    };
  };
in
pkgs.stdenv.mkDerivation {
  pname = "opencode";
  version = data.version;

  src = pkgs.fetchurl {
    url = "https://registry.npmjs.org/@opencode/${packageName}/-/${packageName}-${data.version}.tgz";
    hash = data.packages.${system};
  };

  nativeBuildInputs = [
    pkgs.autoPatchelfHook
    pkgs.makeWrapper
  ];
  buildInputs = [ pkgs.stdenv.cc.cc.lib ];

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 bin/opencode $out/bin/opencode
    wrapProgram $out/bin/opencode \
      --set OPENCODE_PTY_BIN ${opencode-pty}/bin/opencode-pty
    runHook postInstall
  '';

  passthru = { inherit opencode-pty; };

  meta = with pkgs.lib; {
    description = "OpenCode CLI (official npm prebuilt binary)";
    homepage = "https://opencode.ai";
    license = licenses.mit;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "opencode";
    maintainers = [ ];
  };
}
