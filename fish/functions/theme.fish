function theme --description "Change wallpaper and sync colors across the system"
    if test (count $argv) -eq 0
        echo "Usage: theme /path/to/wallpaper.jpg"
        return 1
    end

    # 1. Change wallpaper (Using the correct 'img' subcommand)
    # Added a 'grow' transition for that premium look
    awww img $argv[1] --transition-type grow --transition-duration 1

    # 2. Generate colors with Matugen
    matugen image $argv[1] -m dark

    # 3. Reload Waybar
    killall waybar; waybar &

    # 4. Reload Hyprland
    hyprctl reload
    
    # 5. Reload Dunst
    killall dunst; dunst &

    # 6. Reload Kitty (Safely)
    set kitty_pid (pgrep kitty)
    if test -n "$kitty_pid"
        kill -USR1 $kitty_pid
    end

    notify-send "Theme Applied" "System synced with $(basename $argv[1])"
end
