{
  config,
  lib,
  pkgs,
  ...
}:
{
  # A graphical session picker rather than autologin, so both the Hyprland
  # and niri sessions are selectable. regreet drives greetd's default session
  # (via cage), lists every wayland session it finds in XDG data dirs, and
  # remembers the last user and session on its own.
  services.displayManager.regreet = {
    enable = true;
    theme = {
      package = pkgs.catppuccin-gtk.override {
        accents = [ "lavender" ];
        variant = "macchiato";
        size = "compact";
      };
      name = "catppuccin-macchiato-lavender-compact";
    };
    font = {
      package = pkgs.roboto;
      name = "Roboto";
      # Rendered under GDK_SCALE=2 below, so effectively 22px on the 4K panel.
      size = 11;
    };
    cursorTheme = {
      package = pkgs.catppuccin-cursors.macchiatoLavender;
      name = "catppuccin-macchiato-lavender-cursors";
    };
  };

  # cage runs regreet unscaled, which is unreadably small on a 4K panel. GTK
  # only scales by integers, so double it via the environment. This restates
  # the regreet module's own (mkDefault) command with the env prefix added.
  services.greetd.settings.default_session.command = lib.concatStringsSep " " [
    "${pkgs.coreutils}/bin/env"
    "GDK_SCALE=2"
    "${pkgs.dbus}/bin/dbus-run-session"
    (lib.getExe pkgs.cage)
    "-s"
    "--"
    (lib.getExe config.services.displayManager.regreet.package)
  ];

  # The hyprland package ships hyprland-uwsm.desktop alongside its regular
  # session entry; with uwsm not installed that entry is dead on arrival, and
  # greeters list it anyway (TryExec= is widely ignored). Session lists are
  # aggregated from sessionPackages, so offer a one-file wrapper instead of
  # the full package — hyprland itself stays pristine and binary-cached.
  # mkForce replaces the whole list, so niri's entry is restated here.
  services.displayManager.sessionPackages =
    let
      hyprlandSessionOnly =
        pkgs.runCommand "hyprland-session-entry" { passthru.providedSessions = [ "hyprland" ]; }
          ''
            mkdir -p $out/share/wayland-sessions
            ln -s ${config.programs.hyprland.package}/share/wayland-sessions/hyprland.desktop \
              $out/share/wayland-sessions/hyprland.desktop
          '';
    in
    lib.mkForce [
      hyprlandSessionOnly
      config.programs.niri.package
    ];

  # Enable CPU Power profiles support
  services.power-profiles-daemon.enable = true;

  # A short power-key press suspends instead of powering off — a press aimed
  # at waking a black screen must not be able to shut the machine down.
  # Holding it long still powers off.
  services.logind.settings.Login.HandlePowerKey = "suspend";

  # gnome-keyring's login keyring is encrypted with the password in force
  # when it was created; without this, `passwd` changes the login password but
  # not the keyring's, and auto-unlock silently breaks from then on.
  security.pam.services.passwd.enableGnomeKeyring = true;

  # Enable security services
  services.gnome.gnome-keyring.enable = true;
  security.polkit.enable = true;

  # Portal (screen sharing, file dialogs)
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
  };

  # Cross-device file drops, AirDrop-style.
  programs.localsend = {
    enable = true;
    openFirewall = true;
  };

  # Common packages for Wayland compositors
  environment.systemPackages = with pkgs; [
    # GNOME apps
    file-roller # archive manager
    gnome-calculator
    gnome-text-editor
    evince # PDF viewer
    imv # image viewer
    nautilus # file manager
    sushi # nautilus spacebar preview
    ffmpegthumbnailer # video thumbnails in nautilus
    gnome-disk-utility
    seahorse # keyring manager
    mpv # video player

    # Wayland utilities
    gpu-screen-recorder
    grim
    libnotify
    pamixer
    pavucontrol
    slurp
    wl-clipboard
  ];
}
