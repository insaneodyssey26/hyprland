-- -----------------------------------------------------
-- AUTOSTART
-- -----------------------------------------------------
hl.on("hyprland.start", function()
    -- UI & Status
    hl.exec_cmd("waybar")
    hl.exec_cmd("swaync")
    hl.exec_cmd("awww-daemon && awww restore")
    
    -- System Services
    hl.exec_cmd("hypridle")
    hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
    
    -- Clipboard Management
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    
    -- Environment Updates
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
end)

return true
