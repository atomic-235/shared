{ pkgs }:

pkgs.wl-kbptr.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [
    ./ignore-layout-group.patch
  ];
})
