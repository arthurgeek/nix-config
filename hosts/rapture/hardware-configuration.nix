# Hardware detection for rapture. Regenerate the detected parts with:
#   nixos-generate-config --show-hardware-config
#
# Filesystems are pinned by label rather than UUID so they survive a reinstall
# without editing this file:
#
#   /dev/disk/by-partlabel/nixos-luks   GPT partition label on the LUKS container
#   /dev/mapper/cryptroot               the LUKS mapping, named at unlock time
#   /dev/disk/by-label/NIXBOOT          FAT volume label on the shared ESP
#
# Root is btrfs; every mount below is a subvolume of the same device. @swap was
# added after the install; create it once with:
#
#   sudo mount /dev/mapper/cryptroot /mnt
#   sudo btrfs subvolume create /mnt/@swap
#   sudo umount /mnt
#
# This disk is shared with Windows: /boot is Windows' own EFI System Partition,
# so systemd-boot finds its bootloader and offers it in the menu. Do not
# reformat it.
{
  config,
  lib,
  modulesPath,
  userConfig,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  boot.initrd.luks.devices.cryptroot.device = "/dev/disk/by-partlabel/nixos-luks";

  fileSystems."/" = {
    device = "/dev/mapper/cryptroot";
    fsType = "btrfs";
    options = [
      "subvol=@root"
      "compress=zstd"
      "noatime"
    ];
  };

  fileSystems."/home" = {
    device = "/dev/mapper/cryptroot";
    fsType = "btrfs";
    options = [
      "subvol=@home"
      "compress=zstd"
      "noatime"
    ];
  };

  fileSystems."/nix" = {
    device = "/dev/mapper/cryptroot";
    fsType = "btrfs";
    options = [
      "subvol=@nix"
      "compress=zstd"
      "noatime"
    ];
  };

  # Mounted inside /home but as its own subvolume, so snapshots of @home never
  # contain themselves and restoring @home leaves them untouched. snapper
  # expects exactly this location.
  fileSystems."/home/.snapshots" = {
    device = "/dev/mapper/cryptroot";
    fsType = "btrfs";
    options = [
      "subvol=@snapshots"
      "compress=zstd"
      "noatime"
    ];
  };

  fileSystems."/home/${userConfig.name}/Games" = {
    device = "/dev/mapper/cryptroot";
    fsType = "btrfs";
    # Game assets arrive already compressed, and their large random writes
    # fragment a copy-on-write filesystem badly. nodatacow turns off CoW,
    # checksumming and compression for this subvolume alone.
    options = [
      "subvol=@games"
      "nodatacow"
      "noatime"
    ];
  };

  # Holds only the swapfile. A swapfile must be NOCOW and uncompressed and its
  # subvolume cannot be snapshotted, so it gets one of its own.
  fileSystems."/swap" = {
    device = "/dev/mapper/cryptroot";
    fsType = "btrfs";
    options = [
      "subvol=@swap"
      "noatime"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/NIXBOOT";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  # Inside LUKS, so swapped-out memory and the hibernation image are encrypted.
  # NixOS creates it on first boot with `btrfs filesystem mkswapfile`.
  #
  # Half of the 64 GiB of RAM rather than all of it: the kernel shrinks the
  # hibernation image to 2/5 of RAM (/sys/power/image_size) and compresses it,
  # so 32 GiB is enough unless nearly all memory is in use when hibernating.
  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 32 * 1024;
    }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
