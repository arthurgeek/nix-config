{
  inputs,
  hostname,
  lib,
  nixosModules,
  pkgs,
  userConfig,
  ...
}:
{
  imports = [
    "${inputs.hardware}/common/cpu/intel/cpu-only.nix"
    "${inputs.hardware}/common/gpu/nvidia/blackwell"
    inputs.hardware.nixosModules.common-pc-ssd
    inputs.lanzaboote.nixosModules.lanzaboote

    ./hardware-configuration.nix
    "${nixosModules}/common"
    "${nixosModules}/desktop/niri"
    "${nixosModules}/desktop/hyprland"
    "${nixosModules}/programs/gaming"
  ];

  # Set hostname
  networking.hostName = hostname;

  # Declare the wired connection so ethernet is configured and autoconnects
  # from first boot, rather than depending on a NetworkManager profile that
  # only exists as machine state. Wifi stays available; the wire wins by
  # route metric whenever both are up.
  networking.networkmanager.ensureProfiles.profiles.wired = {
    connection = {
      id = "wired";
      type = "ethernet";
      interface-name = "enp4s0";
      autoconnect = true;
      autoconnect-priority = 100;
    };
    ipv4.method = "auto";
    ipv6.method = "auto";
  };

  # Secure Boot via lanzaboote, which takes over installing systemd-boot and
  # signs it, the kernels and the initrds. Keys are generated into pkiBundle
  # on the first switch and enrolled by systemd-boot on the next boot while
  # the firmware is in Setup Mode (docs/rapture-install.md walks through it).
  # Microsoft's keys are enrolled alongside, or Windows and the NVIDIA card's
  # option ROM would stop loading.
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
    autoGenerateKeys.enable = true;
    autoEnrollKeys.enable = true;

    # systemd-boot's auto-detected Windows Boot Manager entry. It lists last,
    # but boots by default.
    settings.default = "auto-windows";
  };

  # /boot is the EFI System Partition Windows created, which is small. Cap the
  # generations kept there so it cannot fill up and start failing rebuilds.
  # lanzaboote reads this as its own limit.
  boot.loader.systemd-boot.configurationLimit = 5;

  # Monthly read-verify of every block against its checksum. btrfs can only
  # repair what it knows is wrong.
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/" ];
  };

  # Hourly snapshots of /home with pruning. The system needs no equivalent:
  # NixOS generations already cover it.
  services.snapper.configs.home = {
    SUBVOLUME = "/home";
    ALLOW_USERS = [ userConfig.name ];
    SYNC_ACL = true;
    TIMELINE_CREATE = true;
    TIMELINE_CLEANUP = true;
    TIMELINE_LIMIT_HOURLY = 24;
    TIMELINE_LIMIT_DAILY = 7;
    TIMELINE_LIMIT_WEEKLY = 4;
    TIMELINE_LIMIT_MONTHLY = 0;
    TIMELINE_LIMIT_YEARLY = 0;
  };

  # du/df misjudge btrfs: compression and shared extents break their
  # assumptions. These two understand it.
  environment.systemPackages = with pkgs; [
    btdu # sampling disk-usage profiler
    compsize # actual compression ratios
    sbctl # inspect Secure Boot keys and signatures: `sbctl status`, `sbctl verify`
  ];

  # Compressed RAM cache in front of the disk swapfile. Unlike zram it keeps a
  # real swap device behind it, which hibernation needs. With zswap absorbing
  # most swap-out, a high swappiness lets the kernel reclaim cold anonymous
  # pages instead of dropping page cache first.
  boot.zswap.enable = true;
  boot.kernel.sysctl."vm.swappiness" = 100;

  # Resume needs no resume= or resume_offset: systemd stores the swapfile's
  # location in the HibernateLocation EFI variable when hibernating, and the
  # systemd initrd reads it back after unlocking cryptroot.

  # NVIDIA
  hardware.nvidia = {
    modesetting.enable = true;
    # Saves VRAM to disk across suspend and hibernate. Without it the desktop
    # comes back with corrupted or blank surfaces.
    powerManagement.enable = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  system.stateVersion = "26.05";
}
