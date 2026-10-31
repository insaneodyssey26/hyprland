#!/usr/bin/env bash

if [ -z "$1" ]; then
    echo "Usage: theme.sh /path/to/wallpaper.jpg"
    exit 1
fi

WALLPAPER="$1"

# Transition animations (avoids repeating the last one)
ANIMATIONS=("wipe" "wave" "grow" "center" "any" "outer")
LAST_ANIM_FILE="/tmp/awww_last_anim"
LAST_ANIM=$(cat "$LAST_ANIM_FILE" 2>/dev/null)

FILTERED_ANIMS=()
for a in "${ANIMATIONS[@]}"; do
    if [ "$a" != "$LAST_ANIM" ]; then
        FILTERED_ANIMS+=("$a")
    fi
done

RANDOM_ANIM=${FILTERED_ANIMS[$RANDOM % ${#FILTERED_ANIMS[@]}]}
echo "$RANDOM_ANIM" > "$LAST_ANIM_FILE"

awww img "$WALLPAPER" --transition-type "$RANDOM_ANIM" --transition-fps 144 --transition-step 25 --transition-duration 1.5

ln -sf "$WALLPAPER" "$HOME/.current_wallpaper"
matugen image "$WALLPAPER" -m dark --type scheme-fidelity --fallback-color '#6d6d6d' --source-color-index 0

pkill -USR2 waybar
hyprctl reload
swaync-client -rs

KITTY_PIDS=$(pgrep kitty)
if [ -n "$KITTY_PIDS" ]; then
    kill -USR1 $KITTY_PIDS
fi
