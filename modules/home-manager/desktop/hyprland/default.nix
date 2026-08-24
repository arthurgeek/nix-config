{
  config,
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

  # XWayland advertises no DPI of its own, so an X client that sizes itself
  # from "monitor settings" — Steam's own UI scale option among them — falls
  # back to 96dpi and draws at 1x. On a scale-1.5 output under
  # xwayland.force_zero_scaling that lands it on a 3840x2160 surface at native
  # pixels, which is why Steam came out unreadably small however its scaling
  # was configured: STEAM_FORCE_DESKTOPUI_SCALING and -forcedesktopscaling are
  # both inert on current clients, and Steam's in-app toggle had no monitor
  # DPI to match. Xft.dpi is the value those toolkits actually read.
  #
  # 192 = 96 * 2, giving Steam a 2x UI scale. Keeping
  # force_zero_scaling on means this fixes the size without giving up the
  # sharpness that upscaling would cost.
  xresources.properties."Xft.dpi" = 192;

  # cliphist only records while a wl-paste watcher is running, and nothing
  # starts one under Hyprland: caelestia's clipboard picker (SUPER+CTRL+V)
  # reads cliphist's database but never writes to it, so without these the
  # binding opens an empty list forever. niri gets the same watchers from
  # noctalia's own settings, which is why only this session was affected.
  # Text and images need separate watchers -- wl-paste --watch takes one mime
  # class at a time.
  systemd.user.services =
    let
      watcher = type: {
        Unit = {
          Description = "Record clipboard ${type} into cliphist";
          PartOf = [ "hyprland-session.target" ];
          After = [ "hyprland-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --type ${type} --watch ${pkgs.cliphist}/bin/cliphist store";
          Restart = "on-failure";
        };
        Install.WantedBy = [ "hyprland-session.target" ];
      };
    in
    {
      # Nothing loads ~/.Xresources under wayland: there is no X session script
      # to do it, and home-manager only merges it for xsession. XWayland is up
      # by the time the session target is reached, so merge it there.
      xrdb = {
        Unit = {
          Description = "Merge ~/.Xresources into XWayland";
          PartOf = [ "hyprland-session.target" ];
          After = [ "hyprland-session.target" ];
        };
        Service = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "${pkgs.xrdb}/bin/xrdb -merge ${config.home.homeDirectory}/.Xresources";
        };
        Install.WantedBy = [ "hyprland-session.target" ];
      };

      cliphist-text = watcher "text";
      cliphist-image = watcher "image";
    };

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
