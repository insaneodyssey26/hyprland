-- -----------------------------------------------------
-- APPS & CORE BINDS
-- -----------------------------------------------------
hl.bind("SUPER, T", hl.dsp.exec_cmd(terminal))
hl.bind("SUPER, D", hl.dsp.exec_cmd(menu))
hl.bind("SUPER, Q", hl.dsp.killactive())
hl.bind("SUPER, B", hl.dsp.exec_cmd("brave-origin-beta"))
hl.bind("SUPER + SHIFT, B", hl.dsp.exec_cmd("brave-origin-beta --disable-gpu-compositing"))
hl.bind("SUPER, E", hl.dsp.exec_cmd("nemo"))
hl.bind("SUPER + SHIFT, E", hl.dsp.exec_cmd("kitty -e yazi"))
hl.bind("SUPER, C", hl.dsp.exec_cmd("qalculate-gtk"))
hl.bind("SUPER, R", hl.dsp.exec_cmd("rnote"))
hl.bind("SUPER, Y", hl.dsp.exec_cmd("bash -c 'color=$(hyprpicker -a); notify-send \"Color Picked\" \"$color\" -t 2000'"))

-- -----------------------------------------------------
-- NAVIGATION & WINDOW MGMT
-- -----------------------------------------------------
hl.bind("SUPER, left",  hl.dsp.movefocus("l"))
hl.bind("SUPER, right", hl.dsp.movefocus("r"))
hl.bind("SUPER, up",    hl.dsp.movefocus("u"))
hl.bind("SUPER, down",  hl.dsp.movefocus("d"))

hl.bind("SUPER + SHIFT, left",  hl.dsp.movewindow("l"))
hl.bind("SUPER + SHIFT, right", hl.dsp.movewindow("r"))
hl.bind("SUPER + SHIFT, up",    hl.dsp.movewindow("u"))
hl.bind("SUPER + SHIFT, down",  hl.dsp.movewindow("d"))

hl.bind("SUPER, F", hl.dsp.fullscreen())
hl.bind("SUPER, SPACE", hl.dsp.togglefloating())

-- Resizing and Moving (Repeating Binds)
hl.bind("SUPER + CTRL, right", hl.dsp.resizeactive("20 0"), { repeating = true })
hl.bind("SUPER + CTRL, left",  hl.dsp.resizeactive("-20 0"), { repeating = true })
hl.bind("SUPER + CTRL, up",    hl.dsp.resizeactive("0 -20"), { repeating = true })
hl.bind("SUPER + CTRL, down",  hl.dsp.resizeactive("0 20"), { repeating = true })

hl.bind("SUPER + ALT, right", hl.dsp.moveactive("20 0"), { repeating = true })
hl.bind("SUPER + ALT, left",  hl.dsp.moveactive("-20 0"), { repeating = true })
hl.bind("SUPER + ALT, up",    hl.dsp.moveactive("0 -20"), { repeating = true })
hl.bind("SUPER + ALT, down",  hl.dsp.moveactive("0 20"), { repeating = true })

-- Mouse binds
hl.bind("SUPER, mouse:272", hl.dsp.movewindow(), { mouse = true })
hl.bind("SUPER, mouse:273", hl.dsp.resizewindow(), { mouse = true })

-- -----------------------------------------------------
-- WORKSPACES
-- -----------------------------------------------------
for i = 1, 9 do
    hl.bind("SUPER, " .. i, hl.dsp.workspace(tostring(i)))
    hl.bind("SUPER + SHIFT, " .. i, hl.dsp.movetoworkspace(tostring(i)))
end

-- -----------------------------------------------------
-- SYSTEM & MEDIA
-- -----------------------------------------------------
-- Volume & Media
hl.bind(", XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true })
hl.bind(", XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { repeating = true })
hl.bind(", XF86AudioMicMute", hl.dsp.exec_cmd('wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle && notify-send "Microphone" "$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q \'MUTED\' && echo \'Muted\' || echo \'Unmuted\')" -t 1000'))

-- Brightness
hl.bind(", XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 5%+"), { repeating = true })
hl.bind(", XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { repeating = true })

-- Power & Locking
hl.bind("SUPER, L", hl.dsp.exec_cmd("hyprlock & sleep 2 && hyprctl dispatch dpms off"))
hl.bind(", Pause", hl.dsp.exec_cmd("pidof hyprlock && (sleep 0.5 && hyprctl dispatch dpms off)"), { locked = true })
hl.bind("SUPER, Escape", hl.dsp.exec_cmd("~/.config/hypr/scripts/power.sh"))

-- Scripts & Utilities
hl.bind(", PRINT", hl.dsp.exec_cmd("grimblast --freeze copysave screen ~/Pictures/Screenshots/$(date +'%Y-%m-%d_%H-%M-%S').png"))
hl.bind("SUPER, PRINT", hl.dsp.exec_cmd("grimblast --freeze save active - | satty --filename -"))
hl.bind("SUPER, V", hl.dsp.exec_cmd("cliphist list | fuzzel --dmenu | cliphist decode | wl-copy"))
hl.bind("SUPER, X", hl.dsp.exec_cmd("~/.config/hypr/scripts/kill_task.sh"))
hl.bind("SUPER, P", hl.dsp.exec_cmd("~/.config/hypr/scripts/project_launcher.sh"))
hl.bind("SUPER, K", hl.dsp.exec_cmd("~/.config/hypr/scripts/toggle_osk.sh"))
hl.bind("SUPER, period", hl.dsp.exec_cmd("bemoji -p fuzzel"))
hl.bind("SUPER, N", hl.dsp.exec_cmd("swaync-client -t -sw"))
hl.bind("SUPER, H", hl.dsp.exec_cmd("pkill -USR1 waybar"))
hl.bind("SUPER, S", hl.dsp.exec_cmd("~/.config/hypr/scripts/fuzzel_sys.sh"))

-- Themes
hl.bind("SUPER, W", hl.dsp.exec_cmd("~/.config/hypr/scripts/random-wall.fish"))

return true
