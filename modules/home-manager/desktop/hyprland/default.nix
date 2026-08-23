{
  hmModules,
  pkgs,
  ...
}:
let
  # Keybind cheat sheet: reads the live binds from the compositor, so it can
  # never drift from the config. Modmask bits: SHIFT=1 CTRL=4 ALT=8 SUPER=64.
  #
  # Every bind is shown by its description, which lua/keybinds.lua sets on all
  # of them. The dispatcher is useless here: under a lua config Hyprland
  # reports every bind as dispatcher "__lua" with a callback id for an arg, so
  # a description-less bind can only be listed by its keys. Those are dropped
  # rather than printed bare, which also hides the shell's own runtime binds.
  hypr-keys = pkgs.writeShellApplication {
    name = "hypr-keys";
    runtimeInputs = [
      pkgs.jq
      pkgs.fuzzel
    ];
    text = ''
      hyprctl binds -j | jq -r '
        .[] |
        select(.description != "") |
        ([ (if ((.modmask / 64 | floor) % 2) == 1 then "SUPER" else empty end),
           (if ((.modmask / 4  | floor) % 2) == 1 then "CTRL"  else empty end),
           (if ((.modmask / 8  | floor) % 2) == 1 then "ALT"   else empty end),
           (if ( .modmask            % 2) == 1 then "SHIFT" else empty end)
         ] + [ .key ] | join("+")) as $keys |
        "\($keys)	\(.description)"
      ' | sort | column -t -s "$(printf "	")" | fuzzel --dmenu --width 90 --lines 30 --prompt "keys  "
    '';
  };
in
{
  home.packages = [ hypr-keys ];

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
