{ darwinModules, ... }:
{
  imports = [
    "${darwinModules}/common"
  ];

  # Used for backwards compatibility, please read the changelog before changing.
  system.stateVersion = 6;

  system.defaults.CustomUserPreferences = {
    # Required by OmniWM
    "com.apple.spaces"."spans-displays" = 1;
  };

  # The 1Password CLI (`op`). nix-darwin copies it to /usr/local/bin/op, the
  # only path the 1Password app (the cask below) accepts for CLI integration.
  # rapture gets it from modules/nixos/programs/1password.
  programs._1password.enable = true;

  homebrew.casks = [
    "BarutSRB/homebrew-tap/omniwm"
    # 1Password has hardened runtime location checks that break when installed via Nix
    "1password"
    "lens"
    "nordvpn"
    "openmtp"
    "steam"
    "whatsapp"
  ];
}
