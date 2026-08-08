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

    keymap = {
      mgr.prepend_keymap = [
        {
          on = [ "c" "z" ];
          run = ''shell --block -- sh -c 'tar -cf - %s | zstd -3 -o archive.tar.zst && echo "Done: archive.tar.zst" || echo "FAILED"; read -r -p "Press Enter to continue..."' '';
          desc = "Compress to tar.zst";
        }
        {
          on = [ "c" "g" ];
          run = ''shell --block -- sh -c 'tar -czf archive.tar.gz %s && echo "Done: archive.tar.gz" || echo "FAILED"; read -r -p "Press Enter to continue..."' '';
          desc = "Compress to tar.gz";
        }
        {
          on = [ "c" "t" ];
          run = ''shell --block -- sh -c 'tar -cf archive.tar %s && echo "Done: archive.tar" || echo "FAILED"; read -r -p "Press Enter to continue..."' '';
          desc = "Compress to tar";
        }
        {
          on = [ "c" "l" ];
          run = ''shell --block -- sh -c 'tar -cf - %s | lz4 -1 - archive.tar.lz4 && echo "Done: archive.tar.lz4" || echo "FAILED"; read -r -p "Press Enter to continue..."' '';
          desc = "Compress to tar.lz4";
        }
        {
          on = [ "c" "x" ];
          run = ''shell --block -- sh -c 'tar -cf - %s | xz -0 -T0 - archive.tar.xz && echo "Done: archive.tar.xz" || echo "FAILED"; read -r -p "Press Enter to continue..."' '';
          desc = "Compress to tar.xz";
        }
      ];
    };
  };
}
