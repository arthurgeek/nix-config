{
  pkgs,
  ...
}:
{
  xdg = {
    enable = true;

    # Hide the following desktop entries for launcher.
    desktopEntries = {
      uuctl = {
        name = "uuctl";
        noDisplay = true;
      };
      qt6ct = {
        name = "qt6ct";
        noDisplay = true;
      };
      kvantummanager = {
        name = "kvantum";
        noDisplay = true;
      };
    };

    mimeApps = {
      enable = true;
      # Media defaults : mpv for video, imv for images, evince for PDFs
      defaultApplicationPackages = [
        pkgs.gnome-text-editor
        pkgs.imv
        pkgs.mpv
        pkgs.evince
      ];
    };

    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };
}
