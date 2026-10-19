{ pkgs }:

let
  data = builtins.fromJSON (builtins.readFile ./version.json);
  system = pkgs.stdenv.hostPlatform.system;
  packageName = {
    x86_64-linux = "cli-linux-x64";
    aarch64-linux = "cli-linux-arm64";
  }.${system} or (throw "opencode: unsupported system ${system}");
in
pkgs.stdenv.mkDerivation {
  pname = "opencode";
  version = data.version;

  src = pkgs.fetchurl {
    url = "https://registry.npmjs.org/@opencode/${packageName}/-/${packageName}-${data.version}.tgz";
    hash = data.packages.${system};
  };

  nativeBuildInputs = [ pkgs.autoPatchelfHook ];
  buildInputs = [ pkgs.stdenv.cc.cc.lib ];

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 bin/opencode $out/bin/opencode
    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "OpenCode CLI (official npm prebuilt binary)";
    homepage = "https://opencode.ai";
    license = licenses.mit;
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    maintainers = [ ];
  };
}
