{
  inputs,
  hostname,
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

  # /boot is the EFI System Partition Windows created, which is small. Cap the
  # generations kept there so it cannot fill up and start failing rebuilds.
  boot.loader.systemd-boot.configurationLimit = 5;

  # Windows first in the menu and booted by default; NixOS generations below.
  # An explicit entry is needed for the ordering: auto-detected entries carry
  # no sort-key and always sort last, so the auto-detection is switched off
  # and this entry (sort-key "a-windows" < the generations' "nixos") replaces
  # it at the top.
  boot.loader.systemd-boot.extraEntries."windows.conf" = ''
    title Windows 11
    sort-key a-windows
    efi /EFI/Microsoft/Boot/bootmgfw.efi
  '';

  # NixOS rewrites loader.conf's `default` to its own entry on every rebuild
  # and offers no option to change that, so assert the default through the
  # LoaderEntryDefault EFI variable, which takes precedence. auto-entries only
  # hides detected OS entries; the reboot-to-firmware entry is unaffected.
  boot.loader.systemd-boot.extraInstallCommands = ''
    echo "auto-entries no" >> /boot/loader/loader.conf
    ${pkgs.systemd}/bin/bootctl set-default windows.conf
  '';

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
  ];

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
