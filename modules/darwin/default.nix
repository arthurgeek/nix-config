{
  pkgs,
  inputs,
  username,
  ...
}:
{
  imports = [
    inputs.nix-homebrew.darwinModules.nix-homebrew
    inputs.home-manager.darwinModules.home-manager
    ../common
  ];

  # nix-homebrew settings
  nix-homebrew = {
    # Install Homebrew under the default prefix
    enable = true;

    # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
    enableRosetta = true;

    # User owning the Homebrew prefix
    user = username;

    # Declarative tap management
    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
    };

    # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
    # mutableTaps = false;

    # Automatically migrate existing Homebrew installations
    autoMigrate = true;
  };
  environment.systemPackages = [ ];

  # use TouchID for sudo
  security.pam.services.sudo_local.touchIdAuth = true;


  users.users.${username} = {
    home = "/Users/${username}";
    shell = pkgs.fish;
  };

  # Set Git commit hash for darwin-version.
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Homebrew settings
  homebrew = {
    enable = true;

    # Uncomment to install cli packages from Homebrew.
    # brews = [
    #   "mas"
    # ];

    casks = [
      # 1Password & Chrome have hardened runtime location checks
      # that break when installed via Nix
      "1password"
      "google-chrome"
      "nordvpn"
      "whatsapp"
    ];

    # Uncomment to install app store apps using mas-cli.
    # masApps = {
    # };

    # Uncomment to remove any non-specified homebrew packages.
    # onActivation.cleanUp = "zap";

    # Uncomment to automatically update Homebrew and upgrade packages.
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
  };

  # System Settings
  system.primaryUser = username;
  system.defaults = {
    controlcenter = {
      BatteryShowPercentage = true;
    };
    dock.autohide  = true;
    dock.magnification = false;
    dock.mineffect = "genie";
    # Hot corners: TL=screensaver, BL=mission control, BR=desktop
    dock.wvous-tl-corner = 5;
    dock.wvous-tr-corner = null;
    dock.wvous-bl-corner = 2;
    dock.wvous-br-corner = 4;
    finder.FXPreferredViewStyle = "clmv";
    loginwindow.GuestEnabled  = false;
    NSGlobalDomain = {
      AppleICUForce24HourTime = true;
      AppleInterfaceStyle = "Dark";
      AppleKeyboardUIMode = 3;
      InitialKeyRepeat = 20;
      KeyRepeat = 2;
    };
  };
}
