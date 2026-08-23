{ ... }:
{
  # Chrome reads enterprise policy from /etc/opt/chrome/policies/managed, which
  # this module writes — despite the chromium name it emits policy for chromium,
  # chrome and brave alike, and installs no browser of its own (google-chrome
  # stays a home-manager package).
  programs.chromium = {
    enable = true;

    # A Chrome theme is an ordinary extension, so the catppuccin one can be
    # declared here instead of clicked through the Web Store. Macchiato, to
    # match the system flavour; the id is the Web Store id published in
    # https://github.com/catppuccin/chrome.
    #
    # Force-listed extensions are fetched from the Web Store on first launch,
    # so this needs network once, and Chrome will not let the theme be removed
    # from its own UI — swap the flavour here instead.
    extensions = [
      "cmpdlhmnmjhihmcfnigoememnffkimlk" # catppuccin macchiato
    ];
  };
}
