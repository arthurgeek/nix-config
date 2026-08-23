{ nixosModules, pkgs, ... }:
{
  imports = [
    "${nixosModules}/desktop/wayland-common"
  ];

  # Enable Niri
  programs.niri.enable = true;

  # Required for noctalia's calendar. caelestia's calendar is a plain month
  # grid with no events backend, so this is niri-session-only.
  services.gnome.evolution-data-server.enable = true;

  # Enable Xwayland
  environment.systemPackages = with pkgs; [
    xwayland-satellite
  ];
}
