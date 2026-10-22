{ pkgs }:

# Patched tmux: replace ACS-escaped tree-drawing characters with clean
# Unicode box-drawing glyphs in choose-tree mode (├── └── │)
let
  inherit (pkgs) lib;

  # tmux 3.8 moved tree drawing into a format string; older releases build
  # the prefix directly in mode-tree.c.
  cleanTreePatch =
    if lib.versionAtLeast pkgs.tmux.version "3.8" then
      ./clean-tree-lines-3.8.patch
    else
      ./clean-tree-lines-3.7.patch;
in
pkgs.tmux.overrideAttrs (oldAttrs: {
  pname = "tmux-clean-tree";

  patches = (oldAttrs.patches or [ ]) ++ [ cleanTreePatch ];
})
