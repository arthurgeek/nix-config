{ hmModules, ... }:
{
  imports = [
    "${hmModules}/common"
  ];

  # Enable home-manager
  programs.home-manager.enable = true;

  # home-manager sets generateCaches = true by default but package = null on Darwin (see #8723)
  programs.man.generateCaches = false;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "26.05";
}
