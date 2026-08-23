local vars = require("variables")
local mod  = vars.mod

local locked    = { locked = true }
local repeating = { repeating = true }
local release   = { release = true }

--------------------------------------------------------------------------
---- CAELESTIA SHELL -----------------------------------------------------
--------------------------------------------------------------------------
-- These are Hyprland global shortcuts, registered by the shell at runtime.
-- They stay inert until the caelestia systemd unit is up.

-- Tap SUPER alone (SUPER_L is the left Super keysym) and release.
hl.bind(mod .. " + SUPER_L",   hl.dsp.global("caelestia:launcher"), release)
hl.bind(mod .. " + N",         hl.dsp.global("caelestia:sidebar"))
-- The dashboard (clock, calendar, weather, resources) otherwise only opens by
-- hovering the top screen edge — the bar's clock has no popout of its own.
hl.bind(mod .. " + D",         hl.dsp.global("caelestia:dashboard"))
hl.bind(mod .. " + K",         hl.dsp.global("caelestia:showall"))
hl.bind(mod .. " + L",         hl.dsp.global("caelestia:lock"))
hl.bind("CTRL + ALT + Delete", hl.dsp.global("caelestia:session"))
hl.bind("CTRL + ALT + C",      hl.dsp.global("caelestia:clearNotifs"), locked)

-- Screenshots
hl.bind("Print",                     hl.dsp.global("caelestia:screenshot"))
hl.bind(mod .. " + SHIFT + S",       hl.dsp.global("caelestia:screenshotFreeze"))
hl.bind(mod .. " + SHIFT + ALT + S", hl.dsp.global("caelestia:screenshotClip"))

-- Media
hl.bind("XF86AudioPlay",  hl.dsp.global("caelestia:mediaToggle"), locked)
hl.bind("XF86AudioPause", hl.dsp.global("caelestia:mediaToggle"), locked)
hl.bind("XF86AudioNext",  hl.dsp.global("caelestia:mediaNext"),   locked)
hl.bind("XF86AudioPrev",  hl.dsp.global("caelestia:mediaPrev"),   locked)
hl.bind("XF86AudioStop",  hl.dsp.global("caelestia:mediaStop"),   locked)

-- Brightness
hl.bind("XF86MonBrightnessUp",   hl.dsp.global("caelestia:brightnessUp"),   locked)
hl.bind("XF86MonBrightnessDown", hl.dsp.global("caelestia:brightnessDown"), locked)

-- Volume goes straight to pipewire; caelestia's OSD picks the change up.
hl.bind("XF86AudioMute",
    hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), locked)
hl.bind("XF86AudioMicMute",
    hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), locked)
hl.bind("XF86AudioRaiseVolume",
    hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
    { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",
    hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
    { locked = true, repeating = true })

-- Clipboard and emoji (caelestia CLI)
hl.bind("CTRL + " .. mod .. " + V", hl.dsp.exec_cmd("pkill fuzzel || caelestia clipboard"))
hl.bind(mod .. " + Period", hl.dsp.exec_cmd("pkill fuzzel || caelestia emoji -p"))

--------------------------------------------------------------------------
---- APPS ----------------------------------------------------------------
--------------------------------------------------------------------------

hl.bind(mod .. " + T",    hl.dsp.exec_cmd(vars.terminal))
hl.bind(mod .. " + W",    hl.dsp.exec_cmd(vars.browser))
hl.bind(mod .. " + ALT + C", hl.dsp.exec_cmd(vars.editor))
hl.bind(mod .. " + E",    hl.dsp.exec_cmd(vars.fileExplorer))
hl.bind("CTRL + ALT + V", hl.dsp.exec_cmd(vars.audioSettings))

-- Searchable cheat sheet of every bind below, read live from the compositor.
hl.bind(mod .. " + Slash", hl.dsp.exec_cmd("hypr-keys"))

--------------------------------------------------------------------------
---- CLIPBOARD (mac-style) -----------------------------------------------
--------------------------------------------------------------------------
-- SUPER+C/V copy and paste everywhere. Terminals use CTRL+SHIFT+C/V for
-- clipboard (plain CTRL+C is SIGINT there), so the focused window's class
-- picks which shortcut gets forwarded.

local terminal_classes = {
    ["com.mitchellh.ghostty"] = true,
}

local function smart_clip(key)
    return function()
        local w = hl.get_active_window()
        local mods = (w and w.class and terminal_classes[w.class]) and "CTRL SHIFT" or "CTRL"
        hl.send_shortcut({ mods = mods, key = key })
    end
end

hl.bind(mod .. " + C", smart_clip("C"))
hl.bind(mod .. " + V", smart_clip("V"))

-- Window cycling and a scratchpad, from caelestia's dotfiles.
hl.bind("ALT + TAB",         hl.dsp.window.cycle_next(), repeating)
hl.bind("SHIFT + ALT + TAB", hl.dsp.window.cycle_next({ next = false }), repeating)
hl.bind(mod .. " + S",       hl.dsp.workspace.toggle_special("magic"))
hl.bind(mod .. " + ALT + S", hl.dsp.window.move({ workspace = "special:magic" }))

--------------------------------------------------------------------------
---- WINDOWS -------------------------------------------------------------
--------------------------------------------------------------------------

hl.bind(mod .. " + Q",             hl.dsp.window.close())
hl.bind(mod .. " + F",             hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(mod .. " + ALT + F",       hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(mod .. " + ALT + Space",   hl.dsp.window.float())
hl.bind(mod .. " + P",             hl.dsp.window.pin())
hl.bind(mod .. " + mouse:272",     hl.dsp.window.drag(),   { mouse = true })
hl.bind(mod .. " + mouse:273",     hl.dsp.window.resize(), { mouse = true })

--------------------------------------------------------------------------
---- WORKSPACES ----------------------------------------------------------
--------------------------------------------------------------------------

for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + ALT + " .. key,   hl.dsp.window.move({ workspace = i }))
end

hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "m+1" }))
hl.bind(mod .. " + mouse_up",   hl.dsp.focus({ workspace = "m-1" }))
hl.bind("CTRL + " .. mod .. " + Right", hl.dsp.focus({ workspace = "m+1" }), repeating)
hl.bind("CTRL + " .. mod .. " + Left",  hl.dsp.focus({ workspace = "m-1" }), repeating)

--------------------------------------------------------------------------
---- SCROLLING LAYOUT ----------------------------------------------------
--------------------------------------------------------------------------
-- Horizontal movement uses hl.dsp.layout, the scrolling-native dispatcher: it
-- wraps at the ends of the tape and recentres the view instead of falling
-- through to a neighbouring monitor.

hl.bind(mod .. " + left",          hl.dsp.layout("focus l"))
hl.bind(mod .. " + right",         hl.dsp.layout("focus r"))
hl.bind(mod .. " + SHIFT + left",  hl.dsp.layout("swapcol l"))
hl.bind(mod .. " + SHIFT + right", hl.dsp.layout("swapcol r"))

-- Vertical movement uses the generic focus/window.move dispatchers: within-
-- column movement has no scrolling-specific variant.
hl.bind(mod .. " + up",            hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + down",          hl.dsp.focus({ direction = "down" }))
hl.bind(mod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))

-- Column width, adjusted via the scrolling-native resize dispatcher.
hl.bind(mod .. " + Minus", hl.dsp.layout("colresize -0.1"), repeating)
hl.bind(mod .. " + Equal", hl.dsp.layout("colresize +0.1"), repeating)

-- Column move. Uses H/L rather than Left/Right, which are already bound to
-- workspace cycling above.

hl.bind("CTRL + " .. mod .. " + H", hl.dsp.layout("move -col"))
hl.bind("CTRL + " .. mod .. " + L", hl.dsp.layout("move +col"))

-- Column management (niri: consume-or-expel-window-left/right)
hl.bind(mod .. " + bracketleft",  hl.dsp.layout("consume_or_expel prev"))
hl.bind(mod .. " + bracketright", hl.dsp.layout("consume_or_expel next"))

-- Move the focused window out into its own column (niri: expel-window-from-column)
hl.bind(mod .. " + G", hl.dsp.layout("promote"))

-- Cycle the preset widths (niri: switch-preset-column-width)
hl.bind(mod .. " + A",           hl.dsp.layout("colresize +conf"))
hl.bind(mod .. " + SHIFT + A",   hl.dsp.layout("colresize -conf"))

-- Fit operations
hl.bind(mod .. " + O",              hl.dsp.layout("fit visible"))
hl.bind(mod .. " + SHIFT + O",      hl.dsp.layout("fit expand"))
hl.bind("CTRL + " .. mod .. " + F", hl.dsp.layout("fit_into_view"))

-- Freeze the scrolling view for this workspace
hl.bind(mod .. " + I", hl.dsp.layout("inhibit_scroll"))
