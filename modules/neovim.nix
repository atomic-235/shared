{ config, nvimRelativePath, ... }:

{
  xdg.configFile."nvim" = {
    source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/${nvimRelativePath}";
    recursive = true;
  };
}
