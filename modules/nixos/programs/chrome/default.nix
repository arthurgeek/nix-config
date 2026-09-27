{ config, lib, ... }:
{
  # Chrome reads enterprise policy from /etc/opt/chrome/policies/managed, which
  # this module writes — despite the chromium name it emits policy for chromium,
  # chrome and brave alike, and installs no browser of its own (google-chrome
  # stays a home-manager package).
  programs.chromium = {
    enable = true;

    # A Chrome theme is an ordinary extension, so the one matching the system
    # theme (modules/common/theme.nix) can be declared here instead of clicked
    # through the Web Store. Themes without a Chrome extension leave it on
    # Chrome's own.
    #
    # Force-listed extensions are fetched from the Web Store on first launch,
    # so this needs network once, and Chrome will not let the theme be removed
    # from its own UI — switch the system theme instead.
    extensions = lib.optional (
      config.theme.apps.chromeExtension != null
    ) config.theme.apps.chromeExtension;
  };
}
