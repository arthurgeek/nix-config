{ nixosModules, pkgs, ... }:
{
  imports = [
    "${nixosModules}/desktop/wayland-common"
  ];

  # Enable Niri
  programs.niri.enable = true;

  # Required for noctalia calendar support
  services.gnome.evolution-data-server.enable = true;

  # Enable Xwayland
  environment.systemPackages = with pkgs; [
    xwayland-satellite
  ];
}
