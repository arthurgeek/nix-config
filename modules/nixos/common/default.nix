{
  inputs,
  outputs,
  lib,
  config,
  userConfig,
  hostname,
  pkgs,
  ...
}:
{
  imports = [
    "${inputs.self}/modules/common"
    inputs.home-manager.nixosModules.home-manager
    inputs.catppuccin.nixosModules.catppuccin
  ];

  # Register flake inputs for nix commands
  nix.registry = lib.mapAttrs (_: flake: { inherit flake; }) (
    lib.filterAttrs (_: lib.isType "flake") inputs
  );

  # Add inputs to legacy channels
  nix.nixPath = [ "/etc/nix/path" ];
  environment.etc = lib.mapAttrs' (name: value: {
    name = "nix/path/${name}";
    value.source = value.flake;
  }) config.nix.registry;

  # Boot settings
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    consoleLogLevel = 0;
    initrd.systemd.enable = true;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "splash"
      "rd.udev.log_level=3"
    ];
    loader.efi.canTouchEfiVariables = true;
    loader.systemd-boot.enable = true;
    loader.timeout = 5;
    plymouth.enable = true;

    # v4l (virtual camera) module settings
    kernelModules = [ "v4l2loopback" ];
    extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
    extraModprobeConfig = ''
      options v4l2loopback exclusive_caps=1 card_label="Virtual Camera"
    '';
  };

  # Networking
  networking.networkmanager.enable = true;

  # Timezone & locale
  time.timeZone = "America/Sao_Paulo";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };

  # PATH configuration
  environment.localBinInPath = true;

  # Disable CUPS printing
  services.printing.enable = false;

  # Enable devmon for device management
  services.devmon.enable = true;

  # Enable PipeWire for sound
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # User account
  users.users.${userConfig.name} = {
    description = userConfig.fullName;
    extraGroups = [
      "networkmanager"
      "video"
      "wheel"
    ];
    isNormalUser = true;
    shell = pkgs.fish;
  };

  # Passwordless sudo
  security.sudo.wheelNeedsPassword = false;

  # System packages
  environment.systemPackages = with pkgs; [
    gcc # needed for tree-sitter
    gnumake
    killall
  ];

  # Keyboard
  services.xserver.xkb = {
    layout = "us";
    variant = "intl";
  };
  console.keyMap = "us-acentos";

  # Fish shell
  programs.zsh.enable = true;

  # Nvidia
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  environment.sessionVariables = {
    # Wayland support in Chromium and Electron based applications
    NIXOS_OZONE_WL = "1";
    XCURSOR_SIZE = "24";
    # Nvidia
    LIBVA_DRIVER_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };

  # Services
  services.openssh.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  catppuccin = {
    enable = true;
    flavor = "macchiato";
    accent = "lavender";
    cache.enable = true;
    tty.enable = true;
    cursors.enable = true;
  };

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/${userConfig.name}/nix-config";
  };

  # Fonts configuration
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
  ];
}
