{ pkgs }:

pkgs.lazygit.overrideAttrs (oldAttrs: {
  pname = "lazygit-no-donate";

  patches = (oldAttrs.patches or []) ++ [
    ./remove-donate-links.patch
  ];
})
