{ pkgs, ... }:

{
  fonts.packages = with pkgs; [ fira-code nerd-fonts.fira-code ];

  nix.settings.experimental-features = "nix-command flakes";
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 7d";
  };

  programs.fish.enable = true;
  environment.shells = [ pkgs.fish ];
}
