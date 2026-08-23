-- Window rules carried over from the niri config.
--
-- Hyprland matches with Google RE2 regex, NOT Lua patterns. Long-bracket
-- strings [[...]] are used so backslash escapes reach RE2 verbatim instead of
-- being eaten (or rejected) by Lua string escaping.

-- Steam floats rather than taking a tiled column: its own chrome assumes a
-- free-floating window, and every Steam child window (downloads, dialogs,
-- friends) is a separate toplevel that tiling scatters across the tape.
hl.window_rule({
    name  = "steam-windows",
    match = { class = [[^steam$]] },

    workspace = "name:steam",
    float     = true,

    -- Steam has no idle inhibitor of its own, so a long cutscene or a video on
    -- the store page would let the screen lock.
    idle_inhibit = "fullscreen",
})

hl.window_rule({
    name  = "steam-main",
    match = {
        class = [[^steam$]],
        title = [[^Steam$]],
    },

    center = true,
    size   = { 1100, 700 },
})

-- A tall, narrow panel: at the main window's size it is mostly empty space.
hl.window_rule({
    name  = "steam-friends",
    match = {
        class = [[^steam$]],
        title = [[^Friends List$]],
    },

    size = { 460, 800 },
})

-- Steam draws its own translucency into its artwork; the global 0.95 window
-- opacity on top of that muddies it. Matches steam_app_* too, so games render
-- exactly as shipped.
hl.window_rule({
    name  = "steam-opaque",
    match = { class = [[^steam]] },

    opacity = "1 1",
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
