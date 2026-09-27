# The system theme. `theme.name` picks a colour scheme and stylix themes every
# program it supports from it; modules that stylix has no target for read the
# same palette from `config.lib.stylix.colors`. Switching theme is changing
# `theme.name` in modules/common/default.nix.
{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  schemes = "${inputs.tinted-schemes}";

  # Per theme: the stylix scheme, plus the names of the matching built-in or
  # third-party theme for programs stylix has no target for.
  themes = {
    catppuccin-macchiato = {
      # base24: the eight extra slots carry catppuccin's crust, maroon, sky,
      # sapphire and pink, which a base16 scheme has to drop.
      scheme = "${schemes}/base24/catppuccin-macchiato.yaml";
      cursor = {
        package = pkgs.catppuccin-cursors.macchiatoLavender;
        name = "catppuccin-macchiato-lavender-cursors";
      };
      icons = {
        package = pkgs.catppuccin-papirus-folders.override {
          flavor = "macchiato";
          accent = "lavender";
        };
        dark = "Papirus-Dark";
        light = "Papirus-Light";
      };
      herdr = {
        name = "catppuccin";
        light = "catppuccin-latte";
      };
      caelestia = {
        scheme = "catppuccin";
        flavour = "macchiato";
      };
      # Web Store id published in https://github.com/catppuccin/chrome
      chromeExtension = "cmpdlhmnmjhihmcfnigoememnffkimlk";
    };
    nord = {
      scheme = "${schemes}/base16/nord.yaml";
      cursor = {
        package = pkgs.nordzy-cursor-theme;
        name = "Nordzy-cursors";
      };
      icons = {
        package = pkgs.papirus-nord;
        dark = "Papirus-Dark";
        light = "Papirus-Light";
      };
      herdr = {
        name = "nord";
        light = null;
      };
      caelestia = {
        scheme = "nord";
        flavour = "medium";
      };
      chromeExtension = null;
    };
  };
in
{
  options.theme = {
    name = lib.mkOption {
      type = lib.types.enum (builtins.attrNames themes);
      description = "Colour scheme stylix applies to every themed program.";
    };
    apps = lib.mkOption {
      type = lib.types.attrs;
      readOnly = true;
      default = themes.${config.theme.name};
      description = "The selected theme's per-program names, for modules stylix does not theme.";
    };
  };

  config.stylix = {
    enable = true;
    base16Scheme = themes.${config.theme.name}.scheme;
    polarity = "dark";

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.fira-code;
        name = "FiraCode Nerd Font Mono";
      };
      sansSerif = {
        package = pkgs.roboto;
        name = "Roboto";
      };
      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
      sizes.terminal = 18;
    };
  };

  # stylix enables a target for every program it knows, used or not. Its rofi
  # target still sets the renamed `programs.rofi.font`, so it warns on every
  # rebuild; rofi isn't installed, so switch it off. Drop this once stylix
  # moves to `programs.rofi.settings.font`.
  config.home-manager.sharedModules = [ { stylix.targets.rofi.enable = false; } ];
}
