{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.privacy-filter;
in
{
  options.services.privacy-filter = {
    enable = lib.mkEnableOption "local OpenAI Privacy Filter redaction service";
    port = lib.mkOption {
      type = lib.types.port;
      default = 8787;
      description = "Local port for the privacy-filter HTTP service.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.privacy-filter ];

    systemd.user.services.privacy-filter = {
      Unit.Description = "OpenAI Privacy Filter redaction service";
      Service = {
        ExecStart = "${pkgs.privacy-filter}/bin/privacy-filter-server";
        Environment = [ "PRIVACY_FILTER_PORT=${toString cfg.port}" ];
        Restart = "on-failure";
        RestartSec = "5s";
      };
      Install.WantedBy = [ "default.target" ];
    };
  };
}
