{ pkgs, userConfig, ... }:
{
  # Enable greetd to automatically login as `userConfig.name`
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "niri-session";
      user = userConfig.name;
    };
  };

  # Enable CPU Power profiles support
  services.power-profiles-daemon.enable = true;

  # Enable security services
  services.gnome.gnome-keyring.enable = true;
  security.polkit.enable = true;

  # Portal (screen sharing, file dialogs)
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
  };

  # Common packages for Wayland compositors
  environment.systemPackages = with pkgs; [
    # GNOME apps
    file-roller # archive manager
    gnome-calculator
    gnome-text-editor
    loupe # image viewer
    nautilus # file manager
    seahorse # keyring manager
    showtime # Video player

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
