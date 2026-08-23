{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
let
  # Installed by activation as a real, writable file rather than declared
  # through the module (which symlinks it read-only into the store):
  # caelestia rewrites shell.json at startup and toasts an error when it
  # cannot. The repo stays authoritative — drift is overwritten on every
  # rebuild — while the file stays writable at runtime.
  # Subtrees are restated in full (defaults verbatim, deltas commented):
  # caelestia replaces config sections wholesale rather than deep-merging, so
  # a partial subtree silently drops every unmentioned key.
  settings = {
    general = {
      apps = {
        audio = [ "pavucontrol" ];
        playback = [ "mpv" ];
        explorer = [ "nautilus" ]; # delta: thunar upstream
      };

      # Delta: slower spacing than upstream (3/5/10 min), which suspends
      # aggressively for a desktop. A short power-key press wakes it and can
      # never power off (services.logind HandlePowerKey = suspend).
      idle = {
        lockBeforeSleep = true;
        inhibitWhenAudio = true;
        inhibitWhenCharging = false;
        timeouts = [
          {
            timeout = 600;
            idleAction = "lock";
            respectInhibitors = true;
          }
          {
            timeout = 900;
            idleAction = "dpms off";
            returnAction = "dpms on";
          }
          {
            timeout = 1800;
            idleAction = [ "suspend" ];
          }
        ];
      };

      # No battery in this machine; empty warnLevels disables the toasts.
      battery = {
        warnLevels = [ ];
        criticalLevel = 3;
      };
    };

    bar.statusIcons = [
      {
        id = "lockStatus";
        enabled = true;
      }
      {
        id = "audio";
        enabled = false;
      }
      {
        id = "microphone";
        enabled = false;
      }
      {
        id = "kbLayout";
        enabled = false;
      }
      {
        id = "network";
        enabled = true;
      }
      {
        id = "bluetooth";
        enabled = true;
      }
      {
        id = "battery";
        enabled = false; # delta: no battery
      }
    ];

    dashboard = {
      enabled = true;
      showOnHover = true;
      showDashboard = true;
      showMedia = true;
      showPerformance = true;
      showWeather = true;
      mediaUpdateInterval = 500;
      resourceUpdateInterval = 1000;
      dragThreshold = 50;
      performance = {
        showBattery = false; # delta: no battery
        showGpu = true;
        showCpu = true;
        showMemory = true;
        showStorage = true;
        showNetwork = true;
      };
    };
  };
  settingsFile = pkgs.writeText "caelestia-shell.json" (builtins.toJSON settings);
in
{
  imports = [
    inputs.caelestia-shell.homeManagerModules.default
  ];

  programs.caelestia = {
    enable = true;

    # Puts the `caelestia` binary on PATH. The shell package already bundles a
    # copy in its wrapper; the flake-level `caelestia-cli.follows` keeps both on
    # the same rev.
    cli.enable = true;

    # `caelestia scheme set` applies colour templates to everything it knows,
    # including ~/.config/gtk-4.0/gtk.css — a file home-manager owns for the
    # catppuccin theme. That collision breaks every later activation. GTK and
    # Qt theming stay declarative; caelestia themes only its own surfaces.
    cli.settings.theme = {
      enableGtk = false;
      enableQt = false;
    };

    # Bind to the target home-manager's Hyprland module creates rather than the
    # default graphical-session.target, so caelestia does not also start under
    # the niri session.
    systemd.target = "hyprland-session.target";

  };

  home.activation.caelestiaSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run install -Dm644 ${settingsFile} "$HOME/.config/caelestia/shell.json"
  '';

  # The upstream module only restarts the shell when its own symlinked config
  # changes; wire the same restart trigger to our generated file.
  systemd.user.services.caelestia.Unit.X-Restart-Triggers = [ "${settingsFile}" ];

  # The colour scheme lives in $XDG_STATE_HOME/caelestia/scheme.json — mutable
  # state the shell rewrites when you switch schemes from its launcher, so
  # declaring the file outright would make it a read-only symlink and break
  # in-app switching. Instead, seed it on first activation only: the repo owns
  # the default, the runtime owns changes.
  home.activation.caelestiaSchemeSeed = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -e "''${XDG_STATE_HOME:-$HOME/.local/state}/caelestia/scheme.json" ]; then
      run ${config.programs.caelestia.cli.package}/bin/caelestia scheme set -n catppuccin -f macchiato || true
    fi
  '';
}
