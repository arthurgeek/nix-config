-- Window rules carried over from the niri config.
--
-- Hyprland matches with Google RE2 regex, NOT Lua patterns. Long-bracket
-- strings [[...]] are used so backslash escapes reach RE2 verbatim instead of
-- being eaten (or rejected) by Lua string escaping.

-- Steam's main window takes a full-width column on its own workspace.
hl.window_rule({
    name  = "steam-main",
    match = { class = [[^steam$]] },

    workspace       = "name:steam",
    scrolling_width = 1.0,
})

-- Steam games open fullscreen on their own workspace, with tearing and
-- game content type for VRR.
hl.window_rule({
    name  = "steam-games",
    match = {
        class = [[^steam_app_\d+$]],
        -- niri: exclude title="^$" -- skip blank-title helper windows
        title = "negative:^$",
    },

    workspace  = "name:games",
    fullscreen = true,
    content    = "game",
    immediate  = true,
})

-- Floating dialogs.
hl.window_rule({
    name  = "float-pavucontrol",
    match = { class = [[^org\.pulseaudio\.pavucontrol$]] },

    float = true,
})

hl.window_rule({
    name  = "float-calculator",
    match = { class = [[^(gnome-calculator|org\.gnome\.Calculator)$]] },

    float = true,
})
