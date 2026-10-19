{
  lib,
  buildNpmPackage,
  makeWrapper,
  src,
}:

buildNpmPackage {
  pname = "venice-mcp-server";
  version = (lib.importJSON "${src}/package.json").version;

  inherit src;
  npmDepsHash = "sha256-M21aZus6jJ3TMFdWGKy3OxQOkMqwAL/xYGG+mD8D64I=";

  # Rebuild dist/ from src/ (the repo's committed dist/ is stale — it predates
  # the 0.2.0 version bump). `npm run build` runs `tsc`.
  npmFlags = [ "--legacy-peer-deps" ];

  nativeBuildInputs = [ makeWrapper ];

  # Node's native fetch() does not honor http_proxy/https_proxy by default
  # (unlike bun); --use-env-proxy enables it so Venice API calls route through
  # the local proxy. The with-proxy wrapper still does proxy detection + unset
  # no_proxy at the opencode spawn layer.
  postInstall = ''
    wrapProgram "$out/bin/venice-mcp" \
      --set NODE_OPTIONS "--use-env-proxy"
  '';
}
