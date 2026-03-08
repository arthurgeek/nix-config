{ pkgs, ... }:

{
  catppuccin.cursors = {
    enable = true;
    accent = "lavender";
  };
  gtk.enable = true;

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

  home.packages = [ pkgs.nautilus ];
}
