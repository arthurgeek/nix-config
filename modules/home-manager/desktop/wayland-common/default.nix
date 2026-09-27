{
  hmModules,
  ...
}:
{
  imports = [
    "${hmModules}/misc/gtk"
    "${hmModules}/misc/qt"
    "${hmModules}/misc/xdg"
  ];

  # Consistent cursor theme across all applications. The cursor itself comes
  # from stylix (modules/nixos/common, per theme in modules/common/theme.nix).
  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    x11.enable = true;
  };
}
