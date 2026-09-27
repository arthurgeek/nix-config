-- Shared values for the Hyprland config. Required by the sibling files in this
-- directory; never auto-loaded on its own (autoLoad = false in default.nix).

return {
    -- Apps
    terminal      = "ghostty",
    browser       = "google-chrome-stable",
    editor        = "ghostty -e hx",
    fileExplorer  = "nautilus",
    audioSettings = "pavucontrol",

    -- Modifier
    mod = "SUPER",

    -- Colours from the system palette, filled in by default.nix: base07
    -- (catppuccin lavender, nord7), base03, and a faint base11 (catppuccin
    -- crust; base16 schemes fall back to base00).
    activeBorder   = "rgba(@activeBorder@ff)",
    inactiveBorder = "rgba(@inactiveBorder@ff)",
    shadowColor    = "rgba(@shadowColor@10)",
}
