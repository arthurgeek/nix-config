{ hmModules, ... }:
{
  imports = [
    "${hmModules}/desktop/wayland-common"
    # caelestia is imported here rather than in wayland-common so it is scoped
    # to the Hyprland session; the niri session runs noctalia instead.
    "${hmModules}/programs/caelestia"
  ];

  wayland.windowManager.hyprland = {
    enable = true;

    # Hyprland deprecated hyprlang in favour of Lua in 0.55. This is already
    # the default at home.stateVersion 26.05, but is set explicitly so the
    # intent survives a future stateVersion bump.
    configType = "lua";

    # Hyprland itself is installed system-wide by the NixOS module
    # (programs.hyprland), so home-manager must not install a second copy.
    package = null;
    portalPackage = null;

    # Creates hyprland-session.target, which the caelestia unit binds to.
    systemd.enable = true;

    extraLuaFiles = {
      # Required by the sibling files, so it must not be auto-loaded: an
      # auto-loaded entry is require()d at top level as well, executing twice.
      variables = {
        content = ./lua/variables.lua;
        autoLoad = false;
      };

      animations = ./lua/animations.lua;
      general = ./lua/general.lua;
      input = ./lua/input.lua;
      rules = ./lua/rules.lua;
      keybinds = ./lua/keybinds.lua;
    };
  };
}
