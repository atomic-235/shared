{ ... }:

{
  # Zoxide (better cd)
  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    options = [ "--cmd cd" ];
  };

  # fzf integration
  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
  };

  # direnv for per-project environments
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };
}
