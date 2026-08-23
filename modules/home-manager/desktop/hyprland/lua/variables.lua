-- Shared values for the Hyprland config. Required by the sibling files in this
-- directory; never auto-loaded on its own (autoLoad = false in default.nix).

return {
    -- Apps
    terminal      = "ghostty",
    browser       = "google-chrome-stable",
    editor        = "code",
    fileExplorer  = "nautilus",
    audioSettings = "pavucontrol",

    -- Modifier
    mod = "SUPER",

    -- Border colours: catppuccin macchiato, matching the system flavour and
    -- the lavender accent.
    activeBorder   = "rgba(b7bdf8ff)", -- macchiato lavender #b7bdf8
    inactiveBorder = "rgba(5b6078ff)", -- macchiato surface2 #5b6078
}
