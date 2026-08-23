local vars = require("variables")

hl.config({
    general = {
        layout      = "scrolling",

        -- niri: gaps 8
        gaps_in     = 4,
        gaps_out    = 8,

        border_size = 2,

        col = {
            active_border   = vars.activeBorder,
            inactive_border = vars.inactiveBorder,
        },

        allow_tearing    = false,
        resize_on_border = false,
    },

    -- https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/
    scrolling = {
        -- niri: default-column-width { proportion 0.5; }
        column_width             = 0.5,

        -- niri: preset-column-widths { proportion 0.5; proportion 0.66667; }
        explicit_column_widths   = "0.5, 0.66667, 1.0",

        -- niri: center-focused-column "never" -- 1 = fit, 0 = centre
        focus_fit_method         = 1,

        follow_focus             = true,
        fullscreen_on_one_column = true,
        wrap_focus               = true,
        wrap_swapcol             = true,
        direction                = "right",
    },

    -- The look, from caelestia's dotfiles: soft blur behind translucent
    -- surfaces, larger shadows, slightly rounder corners.
    decoration = {
        rounding = 15,

        active_opacity   = 0.95,
        inactive_opacity = 0.95,

        blur = {
            enabled           = true,
            size              = 8,
            passes            = 2,
            ignore_opacity    = true, -- blur through translucent windows
            new_optimizations = true,
            popups            = true,
            input_methods     = true,
            xray              = false,
            special           = false,
        },

        shadow = {
            enabled      = true,
            range        = 15,
            render_power = 4,
            color        = "rgba(18192610)", -- macchiato crust, faint
        },
    },

    -- XWayland apps get bitmap-upscaled under fractional scaling, which
    -- turns their fonts to mush. Render them unscaled instead; apps that can
    -- scale themselves (Steam, below) are told the factor via environment.
    xwayland = {
        force_zero_scaling = true,
    },

    misc = {
        disable_hyprland_logo   = true,
        force_default_wallpaper = 0,

        -- Resizes and drags track the pointer directly; animating them fights it.
        animate_manual_resizes       = false,
        animate_mouse_windowdragging = false,

        -- Wake the screen from dpms-off on input, and focus windows that
        -- request activation (matches the idle timeouts in caelestia's config).
        mouse_move_enables_dpms = true,
        key_press_enables_dpms  = true,
        focus_on_activate       = true,
        middle_click_paste      = false,

        -- niri: output "DP-1" { variable-refresh-rate on-demand=true }
        -- rapture is single-monitor, so the global setting is equivalent and
        -- avoids a per-monitor rule. 2 = fullscreen only.
        vrr = 2,
    },
})
