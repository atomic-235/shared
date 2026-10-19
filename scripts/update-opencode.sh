#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../overlays/opencode"

version="$(curl -fsSL --connect-timeout 10 --max-time 60 https://registry.npmjs.org/@opencode/cli/latest | jq -r .version)"
[ -n "$version" ] && [ "$version" != "null" ] || {
  echo "opencode: failed to resolve latest version" >&2
  exit 1
}

current="$(sed -n 's/^  version = "\(.*\)";$/\1/p' default.nix | head -n1)"
if [ "$version" = "$current" ]; then
  echo "opencode: already at ${version}"
  exit 0
fi

url="https://registry.npmjs.org/@opencode/cli-linux-x64/-/cli-linux-x64-${version}.tgz"
echo "opencode: updating ${current} -> ${version}" >&2
hash="$(nix --extra-experimental-features 'nix-command flakes' store prefetch-file --json "$url" | jq -r .hash)"

sed -i -E \
  "s#^  version = \".*\";#  version = \"${version}\";#; s#sha256-[A-Za-z0-9+/=]+#${hash}#" \
  default.nix

echo "opencode: updated to ${version}" >&2
