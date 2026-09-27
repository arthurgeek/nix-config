{
  config,
  pkgs,
  ...
}:
{
  qt = {
    enable = true;
    platformTheme = {
      name = "qtct";
      package = pkgs.kdePackages.qt6ct;
    };
    # stylix generates the Kvantum theme from the system palette.
    style.name = "kvantum";

    qt6ctSettings = {
      Appearance = {
        icon_theme = config.gtk.iconTheme.name;
      };
    };
  };
}
