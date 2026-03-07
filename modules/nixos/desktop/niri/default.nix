{ pkgs, inputs, ... }:

{
  imports = [
    inputs.noctalia.nixosModules.default
    ../wayland-common
  ];

  programs.niri.enable = true;
  services.noctalia-shell.enable = true;

  environment.systemPackages = [
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
    pkgs.xwayland-satellite
  ];
}
