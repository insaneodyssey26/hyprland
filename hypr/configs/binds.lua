-- -----------------------------------------------------
-- APPS & CORE BINDS
-- -----------------------------------------------------
hl.bind("SUPER + T", hl.dsp.exec_cmd(terminal))
hl.bind("SUPER + D", hl.dsp.exec_cmd(menu))
hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("SUPER + B", hl.dsp.exec_cmd("brave-origin-beta"))
hl.bind("SUPER + SHIFT + B", hl.dsp.exec_cmd("brave-origin-beta --disable-gpu-compositing"))
hl.bind("SUPER + E", hl.dsp.exec_cmd("nemo"))
hl.bind("SUPER + SHIFT + E", hl.dsp.exec_cmd("kitty -e yazi"))
hl.bind("SUPER + C", hl.dsp.exec_cmd("qalculate-gtk"))
hl.bind("SUPER + R", hl.dsp.exec_cmd("rnote"))
hl.bind("SUPER + Y", hl.dsp.exec_cmd("bash -c 'color=$(hyprpicker -a); notify-send \"Color Picked\" \"$color\" -t 2000'"))

-- -----------------------------------------------------
-- NAVIGATION & WINDOW MGMT
-- -----------------------------------------------------
-- Using the exact v0.55.0 syntax for focus
hl.bind("SUPER + left",  hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + right", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + up",    hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + down",  hl.dsp.focus({ direction = "down" }))

-- Window Movement
hl.bind("SUPER + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind("SUPER + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind("SUPER + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind("SUPER + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))

hl.bind("SUPER + F", hl.dsp.window.fullscreen())
hl.bind("SUPER + SPACE", hl.dsp.window.float({ action = "toggle" }))

-- Resizing (relative = true → delta pixels, not absolute)
hl.bind("SUPER + CTRL + right", function() hl.dispatch(hl.dsp.window.resize({ x = 20,  y = 0,   relative = true })) end, { repeating = true })
hl.bind("SUPER + CTRL + left",  function() hl.dispatch(hl.dsp.window.resize({ x = -20, y = 0,   relative = true })) end, { repeating = true })
hl.bind("SUPER + CTRL + up",    function() hl.dispatch(hl.dsp.window.resize({ x = 0,   y = -20, relative = true })) end, { repeating = true })
hl.bind("SUPER + CTRL + down",  function() hl.dispatch(hl.dsp.window.resize({ x = 0,   y = 20,  relative = true })) end, { repeating = true })

-- Moving (relative = true → offset pixels, not absolute position)
hl.bind("SUPER + ALT + right", function() hl.dispatch(hl.dsp.window.move({ x = 20,  y = 0,   relative = true })) end, { repeating = true })
hl.bind("SUPER + ALT + left",  function() hl.dispatch(hl.dsp.window.move({ x = -20, y = 0,   relative = true })) end, { repeating = true })
hl.bind("SUPER + ALT + up",    function() hl.dispatch(hl.dsp.window.move({ x = 0,   y = -20, relative = true })) end, { repeating = true })
hl.bind("SUPER + ALT + down",  function() hl.dispatch(hl.dsp.window.move({ x = 0,   y = 20,  relative = true })) end, { repeating = true })

-- Mouse binds (Exact v0.55.0 syntax)
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- -----------------------------------------------------
-- WORKSPACES
-- -----------------------------------------------------
for i = 1, 9 do
    hl.bind("SUPER + " .. i, hl.dsp.focus({ workspace = i }))
    hl.bind("SUPER + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

-- -----------------------------------------------------
-- SYSTEM & MEDIA
-- -----------------------------------------------------
-- Volume & Media
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true, locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { repeating = true, locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd('wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle && notify-send "Microphone" "$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q \'MUTED\' && echo \'Muted\' || echo \'Unmuted\')" -t 1000'), { locked = true })

-- Brightness
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 5%+"), { repeating = true, locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { repeating = true, locked = true })

-- Power & Locking
hl.bind("SUPER + L", hl.dsp.exec_cmd("hyprlock & sleep 1"), {
    on_complete = hl.dsp.dpms({ action = "off" })
})

-- Pause (Page Break): Native DPMS with 500ms safety timer
hl.bind("Pause", function()
    hl.timer(function()
        hl.dispatch(hl.dsp.dpms({ action = "off" }))
    end, { timeout = 500, type = "oneshot" })
end, { locked = true })

hl.bind("SUPER + Escape", hl.dsp.exec_cmd("~/.config/hypr/scripts/power.sh"))

-- Scripts & Utilities
hl.bind("PRINT", hl.dsp.exec_cmd("grimblast --freeze copysave screen ~/Pictures/Screenshots/$(date +'%Y-%m-%d_%H-%M-%S').png"))
hl.bind("SUPER + PRINT", hl.dsp.exec_cmd("grimblast --freeze save active - | satty --filename -"))
hl.bind("SUPER + V", hl.dsp.exec_cmd("cliphist list | fuzzel --dmenu | cliphist decode | wl-copy"))
hl.bind("SUPER + X", hl.dsp.exec_cmd("~/.config/hypr/scripts/kill_task.sh"))
hl.bind("SUPER + P", hl.dsp.exec_cmd("~/.config/hypr/scripts/project_launcher.sh"))
hl.bind("SUPER + K", hl.dsp.exec_cmd("~/.config/hypr/scripts/toggle_osk.sh"))
hl.bind("SUPER + period", hl.dsp.exec_cmd("bemoji -p fuzzel"))
hl.bind("SUPER + N", hl.dsp.exec_cmd("swaync-client -t -sw"))
hl.bind("SUPER + H", hl.dsp.exec_cmd("pgrep -x waybar && pkill waybar || waybar &"))
hl.bind("SUPER + S", hl.dsp.exec_cmd("~/.config/hypr/scripts/fuzzel_sys.sh"))

-- Themes
hl.bind("SUPER + W", hl.dsp.exec_cmd("~/.config/hypr/scripts/random-wall.fish"))

return true
