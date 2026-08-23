{ ... }:
{
  programs.fastfetch.enable = true;

  # Layout from caelestia's dotfiles (boxed, compact).
  xdg.configFile."fastfetch/config.jsonc".source = ./config.jsonc;
}
