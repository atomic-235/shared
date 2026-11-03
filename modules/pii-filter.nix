{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.pii-filter;
in
{
  options.services.pii-filter = {
    enable = lib.mkEnableOption "local Kiji PII redaction service";
    port = lib.mkOption {
      type = lib.types.port;
      default = 8788;
      description = "Local port for the kiji-pii HTTP service.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.kiji-pii ];

    systemd.user.services.pii-filter = {
      Unit.Description = "Kiji PII redaction service";
      Service = {
        ExecStart = "${pkgs.kiji-pii}/bin/kiji-pii-server";
        Environment = [ "KIJI_PORT=${toString cfg.port}" ];
        Restart = "on-failure";
        RestartSec = "5s";
      };
      Install.WantedBy = [ "default.target" ];
    };
  };
}
