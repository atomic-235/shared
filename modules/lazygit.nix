{ ... }:

{
  programs.lazygit = {
    enable = true;
    settings = {
      disableStartupPopups = true;

      gui = {
        sidePanelWidth = 0.25;
        border = "single";
        theme = {
          activeBorderColor = [ "#7aa2f7" "bold" ];
          inactiveBorderColor = [ "#444b6a" ];
        };
      };

      git = {
        autoFetch = false;
        pagers = [
          { pager = "delta --side-by-side --paging=never"; }
        ];
      };
    };
  };
}
