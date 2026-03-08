{ pkgs, ... }:

{
  fonts.packages = with pkgs; [ fira-code nerd-fonts.fira-code ];

  nix.settings.experimental-features = "nix-command flakes";

  programs.fish.enable = true;
  environment.shells = [ pkgs.fish ];
}
