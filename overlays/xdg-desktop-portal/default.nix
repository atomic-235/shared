{ pkgs }:

pkgs.xdg-desktop-portal.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [
    ./fix-dead-pid-detection.patch
  ];
  # These tests spawn bwrap and fail in GitHub Actions while the same
  # derivation passes locally; they don't exercise the dead-PID patch.
  doCheck = false;
})
