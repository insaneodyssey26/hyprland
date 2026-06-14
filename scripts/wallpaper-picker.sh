#!/usr/bin/env bash

THEME_SCRIPT="$HOME/.config/hypr/scripts/theme.sh"
WALL_DIR="$HOME/wallpapers"

# Dynamically calculate lines (max 15)
WALL_COUNT=$(ls "$WALL_DIR" | wc -l)
if [ "$WALL_COUNT" -gt 15 ]; then
    LINES=15
else
    LINES=$WALL_COUNT
fi

# Show picker
SELECTED_WALL=$(ls "$WALL_DIR" | fuzzel --dmenu -p "Select Wallpaper  " --lines "$LINES" --width 40 --font "Geist:weight=bold:size=10")

# Apply theme if selected
if [ -n "$SELECTED_WALL" ]; then
    bash "$THEME_SCRIPT" "$WALL_DIR/$SELECTED_WALL"
fi
