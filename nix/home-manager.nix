packageFor:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.island;
  settingsFile = "${config.xdg.stateHome}/quickshell/settings.json";
  declared = pkgs.writeText "island-settings.json" (builtins.toJSON cfg.declaredSettings);
  applySettings = "${cfg.package}/libexec/island-apply-settings ${declared} ${lib.escapeShellArg settingsFile}";
  islandctl = "${cfg.package}/bin/islandctl";
  jq = lib.getExe pkgs.jq;
  afterStart = pkgs.writeShellScript "island-after-start" ''
    for _ in $(seq 60); do
      if wallpapers=$(${islandctl} wallpaper list 2>/dev/null); then
        ${lib.optionalString (cfg.wallpaper != null) ''
          if [ "$(${jq} -r '.current // ""' <<<"$wallpapers")" = "" ]; then
            ${islandctl} wallpaper set ${lib.escapeShellArg "${cfg.wallpaper}"}
          fi
        ''}
        ${lib.optionalString (cfg.palette != null) ''
          if [ "$(${islandctl} theme list | ${jq} -r .current)" != ${lib.escapeShellArg cfg.palette} ]; then
            ${islandctl} theme set ${lib.escapeShellArg cfg.palette}
          fi
        ''}
        exit 0
      fi
      sleep 0.5
    done
  '';
in
{
  imports = [ ./settings.nix ];

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
    wallpaper = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Wallpaper applied when none has been picked in the shell yet.";
    };
    hyprland = {
      modifier = lib.mkOption {
        type = lib.types.str;
        default = "SUPER";
        description = "Primary modifier for Island shortcuts.";
      };
      binds = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Bind Island's shortcuts; window and layer rules are always added.";
      };
      look = lib.mkEnableOption "impasto's gaps, rounding and blur";
      lockKey = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "SUPER + ALT + L";
        description = "Key that locks the screen; null leaves locking to the session menu.";
      };
      config = lib.mkOption {
        type = lib.types.lines;
        readOnly = true;
        default = lib.optionalString cfg.enable ''
          dofile("${cfg.package}/share/island/hyprland.lua")(${
            lib.generators.toLua { } (
              {
                inherit (cfg.hyprland) modifier binds look;
                package = toString cfg.package;
              }
              // lib.optionalAttrs (cfg.hyprland.lockKey != null) { inherit (cfg.hyprland) lockKey; }
            )
          })
        '';
        description = "Lua to include in a Lua Hyprland configuration.";
      };
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
          ExecStartPre = "-${applySettings}";
          ExecStart = lib.getExe cfg.package;
          ExecStartPost = "-${afterStart}";
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
