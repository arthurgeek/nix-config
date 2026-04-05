{ hmModules, pkgs, ... }:
{
  imports = [
    "${hmModules}/common"
    "${hmModules}/desktop/niri"
  ];

  # Enable home-manager
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    obsidian
    spotify
    discord
  ];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "26.05";
}
