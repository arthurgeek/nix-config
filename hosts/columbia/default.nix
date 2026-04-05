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

  homebrew.taps = [ "BarutSRB/tap" ];
  homebrew.casks = [
    "BarutSRB/tap/omniwm"
    # 1Password has hardened runtime location checks that break when installed via Nix
    "1password"
    "nordvpn"
    "steam"
    "whatsapp"
  ];
}
