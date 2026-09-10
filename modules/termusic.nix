{ pkgs, ... }:

{
  xdg.configFile."termusic/tui.toml".text = ''
    [theme]
    name = "Tokyonight_Night"
    author = "Folke"
    file_name = "Tokyonight_Night.yml"

    [theme.primary]
    background = "#1a1b26"
    foreground = "#c0caf5"

    [theme.cursor]
    text = "#c0caf5"
    cursor = "#7aa2f7"

    [theme.normal]
    black = "#15161e"
    red = "#f7768e"
    green = "#9ece6a"
    yellow = "#e0af68"
    blue = "#7aa2f7"
    magenta = "#bb9af7"
    cyan = "#7dcfff"
    white = "#a9b1d6"

    [theme.bright]
    black = "#414868"
    red = "#f7768e"
    green = "#9ece6a"
    yellow = "#e0af68"
    blue = "#7aa2f7"
    magenta = "#bb9af7"
    cyan = "#7dcfff"
    white = "#c0caf5"
  '';
}
