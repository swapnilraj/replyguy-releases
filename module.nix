# home-manager module: installs replyguy and starts it with the graphical session.
#   programs.replyguy.enable = true;
# Updates arrive with the user's normal `nix flake update` + switch, which restarts the service.
self:
{ config, lib, pkgs, ... }:
let
  cfg = config.programs.replyguy;
in
{
  options.programs.replyguy = {
    enable = lib.mkEnableOption "replyguy";
    package = lib.mkOption {
      type = lib.types.package;
      default = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
      description = "The replyguy package.";
    };
    autostart = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Start replyguy with the graphical session (a systemd user service on
        graphical-session.target). Window managers started without home-manager's
        xsession may never reach that target; then add `replyguy &` to the startup script instead.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
    systemd.user.services.replyguy = lib.mkIf cfg.autostart {
      Unit = {
        Description = "replyguy";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = lib.getExe cfg.package;
        Restart = "on-failure";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
