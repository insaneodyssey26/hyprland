function theme
    if test (count $argv) -eq 0
        echo "Usage: theme /path/to/wallpaper.jpg"
        return 1
    end

    # High-Performance Animation Fix
    # --transition-fps 144: Matches your screen refresh rate
    # --transition-step 90: Makes the 'grow' circle move faster/smoother
    # --transition-duration 0.8: Snappier feel
    awww img $argv[1] --transition-type grow --transition-fps 144 --transition-step 90 --transition-duration 0.8

    # The rest of your sequence
    matugen image $argv[1] -m dark
    
    killall waybar; waybar & disown
    hyprctl reload
    swaync-client -rs
    
    # Reload Kitty
    set kitty_pid (pgrep kitty)
    if test -n "$kitty_pid"
        kill -USR1 $kitty_pid
    end
end
