function theme
    if test (count $argv) -eq 0
        echo "Usage: theme /path/to/wallpaper.jpg"
        return 1
    end

    set animations wipe wave grow center any outer
    set last_anim_file /tmp/awww_last_anim
    set last_anim (cat $last_anim_file 2>/dev/null)
    
    set filtered_anims
    for a in $animations
        if test "$a" != "$last_anim"
            set filtered_anims $filtered_anims $a
        end
    end
    
    set random_anim (random choice $filtered_anims)
    echo $random_anim > $last_anim_file

    awww img $argv[1] --transition-type $random_anim --transition-fps 144 --transition-step 25 --transition-duration 1.5

    matugen image $argv[1] -m dark --type scheme-fidelity --fallback-color '#6d6d6d' --source-color-index 0
    
    killall waybar; waybar & disown
    hyprctl reload
    swaync-client -rs
    
    set kitty_pid (pgrep kitty)
    if test -n "$kitty_pid"
        kill -USR1 $kitty_pid
    end
end
