{ pkgs, lib, ... }:
let
  font = pkgs.nerd-fonts.fira-code;
in
{
  home.packages = [ font ];

  programs.ghostty = {
    enable = true;
    package = if pkgs.stdenv.hostPlatform.isDarwin then pkgs.ghostty-bin else pkgs.ghostty;
    settings = {
      font-family = "FiraCode Nerd Font Mono";
      font-size = 18;
      macos-option-as-alt = true;
    };
  };
}
