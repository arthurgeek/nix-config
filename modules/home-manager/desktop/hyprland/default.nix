{ hmModules, ... }:
{
  imports = [
    "${hmModules}/desktop/wayland-common"
    # caelestia is imported here rather than in wayland-common so it is scoped
    # to the Hyprland session; the niri session runs noctalia instead.
    "${hmModules}/programs/caelestia"
  ];
}
