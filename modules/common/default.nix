{ pkgs, ... }:

{
  fonts.packages = [ pkgs.fira-code ];

  nix.settings.experimental-features = "nix-command flakes";

  programs.fish.enable = true;
  environment.shells = [ pkgs.fish ];
}
