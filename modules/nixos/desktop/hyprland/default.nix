{ nixosModules, ... }:
{
  imports = [
    "${nixosModules}/desktop/wayland-common"
  ];

  # The NixOS module is required, not optional: it installs the
  # wayland-sessions desktop entry that greetd's session picker reads, and
  # wires up polkit, xwayland and the portal. The default package comes from
  # nixpkgs and is served by cache.nixos.org, so nothing compiles locally.
  programs.hyprland = {
    enable = true;
    withUWSM = false;
  };
}
