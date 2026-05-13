#!/usr/bin/env bash

# 1. Error handling and input check
if [ -z "$1" ]; then
    echo "Usage: theme.sh /path/to/wallpaper.jpg"
    exit 1
fi

WALLPAPER="$1"

# 2. Cinematic Transition Setup (Repeat Protection)
ANIMATIONS=("wipe" "wave" "grow" "center" "any" "outer")
LAST_ANIM_FILE="/tmp/awww_last_anim"
LAST_ANIM=$(cat "$LAST_ANIM_FILE" 2>/dev/null)

# Filter out the last animation
FILTERED_ANIMS=()
for a in "${ANIMATIONS[@]}"; do
    if [ "$a" != "$LAST_ANIM" ]; then
        FILTERED_ANIMS+=("$a")
    fi
done

# Pick a random one from the filtered list
RANDOM_ANIM=${FILTERED_ANIMS[$RANDOM % ${#FILTERED_ANIMS[@]}]}
echo "$RANDOM_ANIM" > "$LAST_ANIM_FILE"

# 3. Trigger Wallpaper Transition
awww img "$WALLPAPER" --transition-type "$RANDOM_ANIM" --transition-fps 144 --transition-step 25 --transition-duration 1.5

# 4. Generate Colors with Matugen
matugen image "$WALLPAPER" -m dark --type scheme-fidelity --fallback-color '#6d6d6d' --source-color-index 0

# 5. Reload Components
killall waybar && waybar & disown
hyprctl reload
swaync-client -rs

# 6. Reload Kitty
KITTY_PIDS=$(pgrep kitty)
if [ -n "$KITTY_PIDS" ]; then
    kill -USR1 $KITTY_PIDS
fi
