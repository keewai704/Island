{ config, lib, ... }:
let
  inherit (lib) mkOption types;
  cfg = config.programs.island;

  setting =
    type: description:
    mkOption {
      type = types.nullOr type;
      default = null;
      inherit description;
    };

  barPiece = types.either types.str (types.attrsOf types.anything);

  typed = {
    barStyle = cfg.bar.style;
    barHeight = cfg.bar.height;
    barHidden = cfg.bar.hidden;
    barLeft = cfg.bar.left;
    barRight = cfg.bar.right;
    chipShape = cfg.bar.chips.shape;
    chipFigure = cfg.bar.chips.figure;
    workspaceStyle = cfg.bar.workspaces.style;
    workspaceCount = cfg.bar.workspaces.count;
    clockFormat = cfg.clock.format;
    clockShowsDate = cfg.clock.date;
    clockShowsSeconds = cfg.clock.seconds;
    fontFamily = cfg.font.family;
    fontMono = cfg.font.mono;
    language = cfg.language;
    weatherPlace = cfg.weather.place;
    githubUser = cfg.github.user;
    idleLock = cfg.idle.lock;
    idleScreen = cfg.idle.screen;
    idleSuspend = cfg.idle.suspend;
    nightLight = cfg.nightLight.enable;
    nightTemperature = cfg.nightLight.temperature;
    desktopTheme = cfg.desktop.theme;
    desktopHidden = cfg.desktop.hidden;
    doNotDisturb = cfg.doNotDisturb;
  };
in
{
  options.programs.island = {
    palette = setting (types.enum [
      "adaptive"
      "catppuccin_mocha"
      "catppuccin_latte"
      "tokyo_night"
      "gruvbox_dark"
      "nord"
      "rose_pine"
      "cyberpunk"
      "bauhaus"
      "crimson"
    ]) "Palette; `adaptive` takes it from the wallpaper.";

    bar = {
      style = setting (types.enum [
        "grouped"
        "spread"
        "island"
      ]) "Grouped round the island, spread to the edges, or all in one capsule.";
      height = setting types.ints.positive "Bar height in pixels.";
      hidden = setting types.bool "Hide the bar.";
      left = setting (types.listOf barPiece) ''
        Pieces left of the island: module ids, `workspaces`, `tray` or `split`
        (a new capsule), or `{ id, shape, figure, when }` for a piece with its
        own look.
      '';
      right = setting (types.listOf barPiece) "Pieces right of the island, as in `bar.left`.";
      chips = {
        shape = setting (types.enum [
          "ring"
          "icon"
        ]) "iPhone Duo style rings, or impasto's plain symbols.";
        figure = setting (types.enum [
          "off"
          "hover"
          "on"
        ]) "When a module's value is written beside it.";
      };
      workspaces = {
        style = setting (types.enum [
          "dots"
          "bars"
          "rings"
          "numbers"
          "roman"
          "kanji"
          "greek"
        ]) "How the workspace strip draws a workspace.";
        count = setting types.ints.positive "Workspaces always shown.";
      };
    };

    clock = {
      format = setting (types.enum [
        "HH:mm"
        "hh:mm AP"
      ]) "24-hour or 12-hour clock.";
      date = setting types.bool "Show the date beside the time.";
      seconds = setting types.bool "Show seconds.";
    };

    font = {
      family = setting types.str "Interface font, or a comma-separated list tried in order.";
      mono = setting types.str "Monospace font for symbols; must be a Nerd Font.";
    };

    language = setting (types.enum [
      "en"
      "es"
    ]) "Interface language.";
    weather.place = setting types.str "Weather location; empty finds it from the network.";
    github.user = setting types.str "GitHub user for the contributions wall.";
    doNotDisturb = setting types.bool "Hold notifications back.";

    idle = {
      lock = setting types.ints.unsigned "Minutes idle before locking; 0 never.";
      screen = setting types.ints.unsigned "Minutes idle before turning screens off; 0 never.";
      suspend = setting types.ints.unsigned "Minutes idle before suspending; 0 never.";
    };

    nightLight = {
      enable = setting types.bool "Warm the screens.";
      temperature = setting types.ints.positive "Night light colour temperature in kelvin.";
    };

    desktop = {
      theme = setting (types.enum [
        "modern"
        "analogue"
        "sticker"
      ]) "How the desktop widgets are drawn.";
      hidden = setting types.bool "Hide the desktop widgets.";
    };

    settings = mkOption {
      type = types.attrsOf types.anything;
      default = { };
      example = {
        notificationTimeout = 8000;
        launcherResults = 12;
      };
      description = ''
        Any other key of the shell's settings.json, written over the shell's
        own value at every start and Home Manager activation. Keys not set here
        or above stay as changed in the shell's Settings.
      '';
    };

    declaredSettings = mkOption {
      type = types.attrsOf types.anything;
      readOnly = true;
      internal = true;
      default = lib.filterAttrs (_: value: value != null) typed // cfg.settings;
      description = "Settings Island applies over settings.json.";
    };
  };
}
