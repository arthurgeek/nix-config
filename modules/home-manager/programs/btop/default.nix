{ ... }:
{
  programs.btop = {
    enable = true;
    # Preferences from caelestia's dotfiles; the colour theme itself comes
    # from the global catppuccin module.
    settings = {
      theme_background = false;
      update_ms = 2000;
      shown_boxes = "cpu mem net proc";
      proc_sorting = "cpu lazy";
      terminal_sync = true;
    };
  };
}
