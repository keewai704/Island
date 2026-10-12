packageFor:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.island;
in
{
  options.programs.island = {
    enable = lib.mkEnableOption "Island, impasto's Quickshell shell for Hyprland";
    package = lib.mkOption {
      type = lib.types.package;
      default = packageFor pkgs;
      defaultText = lib.literalMD "Island built with the consuming host's packages";
      description = "Island package.";
    };
    wallpapers = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Link impasto's paintings into the wallpaper folder.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      cfg.package
      pkgs.inter
      pkgs.nerd-fonts.jetbrains-mono
      pkgs.papirus-icon-theme
    ];
    fonts.fontconfig.enable = true;

    xdg.dataFile."wallpapers" = lib.mkIf cfg.wallpapers {
      source = "${cfg.package}/share/island/wallpapers";
      recursive = true;
    };

    systemd.user.services = {
      island = {
        Unit = {
          Description = "Island shell";
          After = [
            "graphical-session.target"
            "awww.service"
          ];
          Wants = [ "awww.service" ];
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = lib.getExe cfg.package;
          Restart = "on-failure";
          RestartSec = 2;
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
      awww = {
        Unit = {
          Description = "awww wallpaper daemon";
          After = [ "graphical-session.target" ];
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = lib.getExe' pkgs.awww "awww-daemon";
          Restart = "on-failure";
          RestartSec = 1;
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
