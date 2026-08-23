local vars = require("variables")
local mod  = vars.mod

local locked    = { locked = true }
local repeating = { repeating = true }
local release   = { release = true }

-- Every bind carries a description. Under a Lua config `hyprctl binds -j`
-- reports each bind's dispatcher as "__lua" and its arg as a callback id, so
-- the description field is the only human-readable thing the Super+/ cheat
-- sheet (hypr-keys) has to show. The shared option tables above are reused
-- across binds and must not be mutated, hence the copy.
local function d(description, base)
    local o = { description = description }
    for k, v in pairs(base or {}) do
        o[k] = v
    end
    return o
end

--------------------------------------------------------------------------
---- CAELESTIA SHELL -----------------------------------------------------
--------------------------------------------------------------------------
-- These are Hyprland global shortcuts, registered by the shell at runtime.
-- They stay inert until the caelestia systemd unit is up.

-- Tap SUPER alone (SUPER_L is the left Super keysym) and release.
hl.bind(mod .. " + SUPER_L",   hl.dsp.global("caelestia:launcher"), d("App launcher", release))
hl.bind(mod .. " + N",         hl.dsp.global("caelestia:sidebar"), d("Notification sidebar"))
-- The dashboard (clock, calendar, weather, resources) otherwise only opens by
-- hovering the top screen edge — the bar's clock has no popout of its own.
hl.bind(mod .. " + D",         hl.dsp.global("caelestia:dashboard"), d("Dashboard: calendar, weather, resources"))
hl.bind(mod .. " + K",         hl.dsp.global("caelestia:showall"), d("Show all windows"))
hl.bind(mod .. " + L",         hl.dsp.global("caelestia:lock"), d("Lock the screen"))
hl.bind("CTRL + ALT + Delete", hl.dsp.global("caelestia:session"), d("Session menu: log out, reboot, shut down"))
hl.bind("CTRL + ALT + C",      hl.dsp.global("caelestia:clearNotifs"), d("Clear all notifications", locked))

-- Screenshots
hl.bind("Print",                     hl.dsp.global("caelestia:screenshot"), d("Screenshot a region"))
hl.bind(mod .. " + SHIFT + S",       hl.dsp.global("caelestia:screenshotFreeze"), d("Screenshot a region, screen frozen"))
hl.bind(mod .. " + SHIFT + ALT + S", hl.dsp.global("caelestia:screenshotClip"), d("Screenshot a region to the clipboard"))

-- Media
hl.bind("XF86AudioPlay",  hl.dsp.global("caelestia:mediaToggle"), d("Play/pause", locked))
hl.bind("XF86AudioPause", hl.dsp.global("caelestia:mediaToggle"), d("Play/pause", locked))
hl.bind("XF86AudioNext",  hl.dsp.global("caelestia:mediaNext"),   d("Next track", locked))
hl.bind("XF86AudioPrev",  hl.dsp.global("caelestia:mediaPrev"),   d("Previous track", locked))
hl.bind("XF86AudioStop",  hl.dsp.global("caelestia:mediaStop"),   d("Stop playback", locked))

-- Brightness
hl.bind("XF86MonBrightnessUp",   hl.dsp.global("caelestia:brightnessUp"),   d("Brightness up", locked))
hl.bind("XF86MonBrightnessDown", hl.dsp.global("caelestia:brightnessDown"), d("Brightness down", locked))

-- Volume goes straight to pipewire; caelestia's OSD picks the change up.
hl.bind("XF86AudioMute",
    hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), d("Mute output", locked))
hl.bind("XF86AudioMicMute",
    hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), d("Mute microphone", locked))
hl.bind("XF86AudioRaiseVolume",
    hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
    d("Volume up", { locked = true, repeating = true }))
hl.bind("XF86AudioLowerVolume",
    hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
    d("Volume down", { locked = true, repeating = true }))

-- Clipboard and emoji (caelestia CLI)
hl.bind("CTRL + " .. mod .. " + V", hl.dsp.exec_cmd("pkill fuzzel || caelestia clipboard"), d("Clipboard history"))
hl.bind(mod .. " + Period", hl.dsp.exec_cmd("pkill fuzzel || caelestia emoji -p"), d("Emoji picker"))

--------------------------------------------------------------------------
---- APPS ----------------------------------------------------------------
--------------------------------------------------------------------------

hl.bind(mod .. " + T",       hl.dsp.exec_cmd(vars.terminal), d("Terminal"))
hl.bind(mod .. " + W",       hl.dsp.exec_cmd(vars.browser), d("Browser"))
hl.bind(mod .. " + ALT + C", hl.dsp.exec_cmd(vars.editor), d("Editor"))
hl.bind(mod .. " + E",       hl.dsp.exec_cmd(vars.fileExplorer), d("File manager"))
hl.bind("CTRL + ALT + V",    hl.dsp.exec_cmd(vars.audioSettings), d("Audio settings"))

-- Searchable cheat sheet of every bind below, read live from the compositor.
hl.bind(mod .. " + Slash", hl.dsp.exec_cmd("hypr-keys"), d("This cheat sheet"))

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

hl.bind(mod .. " + C", smart_clip("C"), d("Copy"))
hl.bind(mod .. " + V", smart_clip("V"), d("Paste"))

-- Window cycling and a scratchpad, from caelestia's dotfiles.
hl.bind("ALT + TAB",         hl.dsp.window.cycle_next(), d("Cycle windows", repeating))
hl.bind("SHIFT + ALT + TAB", hl.dsp.window.cycle_next({ next = false }), d("Cycle windows backwards", repeating))
hl.bind(mod .. " + S",       hl.dsp.workspace.toggle_special("magic"), d("Toggle the scratchpad"))
hl.bind(mod .. " + ALT + S", hl.dsp.window.move({ workspace = "special:magic" }), d("Send window to the scratchpad"))

--------------------------------------------------------------------------
---- WINDOWS -------------------------------------------------------------
--------------------------------------------------------------------------

hl.bind(mod .. " + Q",             hl.dsp.window.close(), d("Close window"))
hl.bind(mod .. " + F",             hl.dsp.window.fullscreen({ mode = "fullscreen" }), d("Fullscreen"))
hl.bind(mod .. " + ALT + F",       hl.dsp.window.fullscreen({ mode = "maximized" }), d("Maximise"))
hl.bind(mod .. " + ALT + Space",   hl.dsp.window.float(), d("Toggle floating"))
hl.bind(mod .. " + P",             hl.dsp.window.pin(), d("Pin above other windows"))
hl.bind(mod .. " + mouse:272",     hl.dsp.window.drag(),   d("Drag window", { mouse = true }))
hl.bind(mod .. " + mouse:273",     hl.dsp.window.resize(), d("Resize window", { mouse = true }))

--------------------------------------------------------------------------
---- WORKSPACES ----------------------------------------------------------
--------------------------------------------------------------------------

for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mod .. " + " .. key,       hl.dsp.focus({ workspace = i }), d("Go to workspace " .. i))
    hl.bind(mod .. " + ALT + " .. key, hl.dsp.window.move({ workspace = i }), d("Send window to workspace " .. i))
end

hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "m+1" }), d("Next workspace"))
hl.bind(mod .. " + mouse_up",   hl.dsp.focus({ workspace = "m-1" }), d("Previous workspace"))
hl.bind("CTRL + " .. mod .. " + Right", hl.dsp.focus({ workspace = "m+1" }), d("Next workspace", repeating))
hl.bind("CTRL + " .. mod .. " + Left",  hl.dsp.focus({ workspace = "m-1" }), d("Previous workspace", repeating))

--------------------------------------------------------------------------
---- SCROLLING LAYOUT ----------------------------------------------------
--------------------------------------------------------------------------
-- Horizontal movement uses hl.dsp.layout, the scrolling-native dispatcher: it
-- wraps at the ends of the tape and recentres the view instead of falling
-- through to a neighbouring monitor.

hl.bind(mod .. " + left",          hl.dsp.layout("focus l"), d("Focus column left"))
hl.bind(mod .. " + right",         hl.dsp.layout("focus r"), d("Focus column right"))
hl.bind(mod .. " + SHIFT + left",  hl.dsp.layout("swapcol l"), d("Swap column left"))
hl.bind(mod .. " + SHIFT + right", hl.dsp.layout("swapcol r"), d("Swap column right"))

-- Vertical movement uses the generic focus/window.move dispatchers: within-
-- column movement has no scrolling-specific variant.
hl.bind(mod .. " + up",            hl.dsp.focus({ direction = "up" }), d("Focus window above"))
hl.bind(mod .. " + down",          hl.dsp.focus({ direction = "down" }), d("Focus window below"))
hl.bind(mod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }), d("Move window up in column"))
hl.bind(mod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }), d("Move window down in column"))

-- Column width, adjusted via the scrolling-native resize dispatcher.
hl.bind(mod .. " + Minus", hl.dsp.layout("colresize -0.1"), d("Narrow the column", repeating))
hl.bind(mod .. " + Equal", hl.dsp.layout("colresize +0.1"), d("Widen the column", repeating))

-- Column move. Uses H/L rather than Left/Right, which are already bound to
-- workspace cycling above.

hl.bind("CTRL + " .. mod .. " + H", hl.dsp.layout("move -col"), d("Move column left"))
hl.bind("CTRL + " .. mod .. " + L", hl.dsp.layout("move +col"), d("Move column right"))

-- Column management (niri: consume-or-expel-window-left/right)
hl.bind(mod .. " + bracketleft",  hl.dsp.layout("consume_or_expel prev"), d("Pull the previous window into this column"))
hl.bind(mod .. " + bracketright", hl.dsp.layout("consume_or_expel next"), d("Push this window into the next column"))

-- Move the focused window out into its own column (niri: expel-window-from-column)
hl.bind(mod .. " + G", hl.dsp.layout("promote"), d("Give this window its own column"))

-- Cycle the preset widths (niri: switch-preset-column-width)
hl.bind(mod .. " + A",           hl.dsp.layout("colresize +conf"), d("Cycle preset column widths"))
hl.bind(mod .. " + SHIFT + A",   hl.dsp.layout("colresize -conf"), d("Cycle preset column widths backwards"))

-- Fit operations
hl.bind(mod .. " + O",              hl.dsp.layout("fit visible"), d("Fit visible columns to the screen"))
hl.bind(mod .. " + SHIFT + O",      hl.dsp.layout("fit expand"), d("Expand the column to fill free space"))
hl.bind("CTRL + " .. mod .. " + F", hl.dsp.layout("fit_into_view"), d("Scroll the focused column into view"))

-- Freeze the scrolling view for this workspace
hl.bind(mod .. " + I", hl.dsp.layout("inhibit_scroll"), d("Freeze scrolling on this workspace"))
