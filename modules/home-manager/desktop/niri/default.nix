{ hmModules, ... }:
{
  imports = [
    "${hmModules}/desktop/wayland-common"
    # noctalia is imported here rather than in wayland-common so it is scoped
    # to the niri session; the Hyprland session runs caelestia instead.
    "${hmModules}/programs/noctalia"
  ];

  xdg.configFile."niri/config.kdl".source = ./config.kdl;
}
