{ pkgs }:

# Patched tmux: replace ACS-escaped tree-drawing characters with clean
# Unicode box-drawing glyphs in choose-tree mode (├── └── │)
pkgs.tmux.overrideAttrs (oldAttrs: {
  pname = "tmux-clean-tree";

  patches = (oldAttrs.patches or []) ++ [
    ./clean-tree-lines.patch
  ];
})
