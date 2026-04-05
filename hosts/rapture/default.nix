{
  inputs,
  hostname,
  nixosModules,
  ...
}:
{
  imports = [
    "${inputs.hardware}/common/cpu/intel/cpu-only.nix"
    "${inputs.hardware}/common/gpu/nvidia/blackwell"
    inputs.hardware.nixosModules.common-pc-ssd

    ./hardware-configuration.nix
    "${nixosModules}/common"
    "${nixosModules}/desktop/niri"
    "${nixosModules}/programs/gaming"
  ];

  # Set hostname
  networking.hostName = hostname;

  # NVIDIA
  hardware.nvidia = {
    modesetting.enable = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  system.stateVersion = "26.05";
}
