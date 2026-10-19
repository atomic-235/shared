{ pkgs }:

pkgs.waybar.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [
    ./lua-dispatch.patch
  ];
})
