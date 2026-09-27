{
  config,
  pkgs,
  ...
}:
{
  # Theme, cursor and font come from stylix (modules/common/theme.nix).
  gtk = {
    enable = true;
    colorScheme = "dark";
    gtk2.force = true;
    gtk3 = {
      bookmarks = [
        "file://${config.home.homeDirectory}/Documents"
        "file://${config.home.homeDirectory}/Downloads"
        "file://${config.home.homeDirectory}/Pictures"
        "file://${config.home.homeDirectory}/Videos"
      ];
    };
  };
}
