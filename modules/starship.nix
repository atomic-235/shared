{ ... }:

{
  programs.starship = {
    enable = true;
    settings = {
      format = "$all$time$cmd_duration$line_break$character";
      time = {
        disabled = false;
        format = "[󰥔 $time](bold)";
        time_format = "%T";
      };
      cmd_duration = {
        format = " [\\(took $duration\\)](bold) ";
      };
      directory = {
        home_symbol = "";
        truncation_length = 3;
      };
    };
  };
}
