{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

# The language server lives in the Quint monorepo under
# vscode/quint-vscode/server and is not published to nixpkgs. Version tracks
# the monorepo tag; the npm package itself is at 0.20.0.
buildNpmPackage rec {
  pname = "quint-language-server";
  version = "0.33.1";

  src = fetchFromGitHub {
    owner = "quint-co";
    repo = "quint";
    tag = "v${version}";
    hash = "sha256-F0Yj9e+qTOlj6RzspvkEhilXC6pFHvISBRLgvJmon7I=";
  };

  sourceRoot = "${src.name}/vscode/quint-vscode/server";

  # Upstream imports this type from the VS Code extension's dependency, which
  # is not declared in the server's package.json. The LSP package exports the
  # same type.
  postPatch = ''
    substituteInPlace src/complete.ts \
      --replace-fail "from 'vscode-languageclient'" "from 'vscode-languageserver'"
  '';

  npmDepsHash = "sha256-Y0p5mYc8JsjnsBz0MQCEZl41NoDQeq/zAwxNJBRA4fI=";

  npmBuildScript = "compile";

  meta = {
    description = "Language server for the Quint specification language";
    homepage = "https://quint.sh";
    license = lib.licenses.asl20;
    mainProgram = "quint-language-server";
    platforms = lib.platforms.unix;
  };
}
