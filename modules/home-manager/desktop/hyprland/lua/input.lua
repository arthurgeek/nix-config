hl.config({
    input = {
        -- Matches services.xserver.xkb in modules/nixos/common
        kb_layout    = "us",
        kb_variant   = "intl",

        repeat_delay = 250,
        repeat_rate  = 40,

        -- niri: focus-follows-mouse max-scroll-amount="0%"
        follow_mouse = 1,

        -- niri: mouse { accel-profile "flat" }
        accel_profile = "flat",

        -- niri: touchpad { tap; natural-scroll; }
        touchpad = {
            tap_to_click   = true,
            natural_scroll = true,
        },
    },
})

hl.monitor({
    output   = "DP-1",
    -- 4K at 27": preferred mode picks 60Hz, so ask for the panel's real
    -- refresh rate explicitly. scale 1.5 sizes the UI like 1440p while
    -- keeping 4K sharpness.
    mode     = "3840x2160@160",
    position = "auto",
    scale    = 1.5,
})
