{
  config,
  lib,
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

    # User owning the Homebrew prefix
    user = userConfig.name;

    # Declarative tap management
    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
      "BarutSRB/homebrew-tap" = inputs.homebrew-barutsrb-tap;
    };

    # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
    mutableTaps = false;
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
    taps = builtins.attrNames config.nix-homebrew.taps;

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

    # Cleanup is handled by the activation script below, NOT here. nix-darwin
    # (incl. current master a1fa429) still emits the obsolete
    # `brew bundle --force-cleanup`, which Homebrew 6.0 removed in favour of the
    # separate `brew bundle cleanup` subcommand; leaving this as "zap"/"uninstall"
    # aborts activation with `invalid option: --force-cleanup` (nix-darwin#1807).
    onActivation.cleanup = "none";

    # Uncomment to automatically update Homebrew and upgrade packages.
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
  };

  # Re-add the "zap" cleanup that `onActivation.cleanup` would normally do, using
  # Homebrew 6.0's `brew bundle cleanup` subcommand. `mkAfter` appends this after
  # nix-darwin's own `brew bundle` (install) step in the same activation script.
  # The Brewfile is regenerated from the same `config.homebrew.brewfile` text
  # nix-darwin installs from, so cleanup zaps exactly what isn't declared.
  # Remove this block and restore `onActivation.cleanup = "zap"` once nix-darwin
  # emits the `brew bundle cleanup` subcommand natively.
  system.activationScripts.homebrew.text = lib.mkAfter ''
    if [ -f /opt/homebrew/bin/brew ]; then
      echo >&2 "Homebrew cleanup (zap)..."
      PATH="/opt/homebrew/bin:$PATH" sudo --preserve-env=PATH \
        --user=${userConfig.name} --set-home \
        env HOMEBREW_NO_AUTO_UPDATE=1 \
        brew bundle cleanup \
          --file="${pkgs.writeText "Brewfile" config.homebrew.brewfile}" \
          --zap --force
    fi
  '';

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
