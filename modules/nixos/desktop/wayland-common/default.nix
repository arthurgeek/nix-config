{ pkgs, username, ... }:

{
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "niri-session";
      user = username;
    };
  };

  # Security
  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;

  # Audio
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # Portal (screen sharing, file dialogs)
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
  };

  # Hardware
  hardware.bluetooth.enable = true;
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;

  # Common Wayland packages
  environment.systemPackages = with pkgs; [
    grim
    slurp
    libnotify
    pamixer
    pavucontrol
    wl-clipboard
  ];
}
