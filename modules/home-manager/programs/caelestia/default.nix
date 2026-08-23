{
  inputs,
  config,
  lib,
  ...
}:
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

    # Bind to the target home-manager's Hyprland module creates rather than the
    # default graphical-session.target, so caelestia does not also start under
    # the niri session.
    systemd.target = "hyprland-session.target";
  };

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
