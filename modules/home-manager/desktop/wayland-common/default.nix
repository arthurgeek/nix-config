{
  config,
  hmModules,
  ...
}:
{
  imports = [
    "${hmModules}/misc/gtk"
    "${hmModules}/misc/qt"
    "${hmModules}/misc/xdg"
    "${hmModules}/programs/noctalia"
  ];

  # Consistent cursor theme across all applications.
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = config.gtk.cursorTheme.package;
    name = config.gtk.cursorTheme.name;
    size = config.gtk.cursorTheme.size;
  };
}
