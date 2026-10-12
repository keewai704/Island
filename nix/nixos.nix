{ config, lib, ... }:
{
  options.programs.island.enable = lib.mkEnableOption "the system services Island reads from";

  config = lib.mkIf config.programs.island.enable {
    programs.hyprland.enable = lib.mkDefault true;
    networking.networkmanager.enable = lib.mkDefault true;
    hardware.bluetooth.enable = lib.mkDefault true;
    security.rtkit.enable = true;
    services = {
      upower.enable = true;
      power-profiles-daemon.enable = lib.mkDefault true;
      pipewire = {
        enable = lib.mkDefault true;
        pulse.enable = lib.mkDefault true;
      };
    };
  };
}
