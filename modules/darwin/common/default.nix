{
  pkgs,
  inputs,
  outputs,
  userConfig,
  ...
}:
{
  imports = [
    "${inputs.self}/modules/common"
    inputs.nix-homebrew.darwinModules.nix-homebrew
    inputs.home-manager.darwinModules.home-manager
  ];

  # nix-homebrew settings
  nix-homebrew = {
    # Install Homebrew under the default prefix
    enable = true;

    # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
    enableRosetta = true;

    # User owning the Homebrew prefix
    user = userConfig.name;

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

  users.users.${userConfig.name} = {
    name = userConfig.name;
    home = "/Users/${userConfig.name}";
    shell = pkgs.fish;
  };

  # Add ability to use TouchID for sudo
  security.pam.services.sudo_local.touchIdAuth = true;

  # Passwordless sudo
  security.sudo.extraConfig = "${userConfig.name}    ALL = (ALL) NOPASSWD: ALL";

  # Homebrew settings
  homebrew = {
    enable = true;

    # Uncomment to install cli packages from Homebrew.
    # brews = [
    #   "mas"
    # ];

    casks = [
      # Chrome has hardened runtime location checks that break when installed via Nix
      "google-chrome"
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

  # System settings
  system = {
    # Set Git commit hash for darwin-version.
    configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

    defaults = {
      controlcenter = {
        BatteryShowPercentage = true;
      };
      NSGlobalDomain = {
        AppleICUForce24HourTime = true;
        AppleInterfaceStyle = "Dark";
        AppleKeyboardUIMode = 2;
        InitialKeyRepeat = 20;
        KeyRepeat = 2;
      };
      finder = {
        FXPreferredViewStyle = "clmv";
      };
      dock = {
        autohide = true;
        magnification = false;
        mineffect = "genie";
        show-recents = false;
        showhidden = true;
        # Hot corners: TL=screensaver, BL=mission control, BR=desktop
        wvous-tl-corner = 5;
        wvous-tr-corner = 1;
        wvous-bl-corner = 2;
        wvous-br-corner = 4;
      };
      loginwindow = {
        GuestEnabled = false;
      };
    };
    primaryUser = userConfig.name;
  };

}
