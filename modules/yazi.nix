{ pkgs, ... }:

let
  tokyo-night-yazi = pkgs.fetchFromGitHub {
    owner = "BennyOe";
    repo = "tokyo-night.yazi";
    rev = "8e6296f14daff24151c736ebd0b9b6cd89b02b03";
    hash = "sha256-LArhRteD7OQRBguV1n13gb5jkl90sOxShkDzgEf3PA0=";
  };
in
{
  programs.yazi = {
    enable = true;
    enableBashIntegration = true;
    shellWrapperName = "yy";

    flavors = {
      tokyo-night = tokyo-night-yazi;
    };

    theme = {
      flavor = {
        dark = "tokyo-night";
        light = "tokyo-night";
      };
    };

    settings = {
      manager = {
        ratio = [
          1
          4
          3
        ];
        sort_by = "natural";
        sort_sensitive = false;
        sort_reverse = false;
        sort_dir_first = true;
        linemode = "size";
        show_hidden = false;
        show_symlink = true;
        scrolloff = 5;
      };

      preview = {
        tab_size = 2;
        max_width = 600;
        max_height = 900;
      };
    };
  };
}
