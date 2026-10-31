#!/usr/bin/env bash

THEME_SCRIPT="$HOME/.config/hypr/scripts/theme.sh"
WALL_DIR="$HOME/wallpapers"

WALL_COUNT=$(ls "$WALL_DIR" | wc -l)
if [ "$WALL_COUNT" -gt 15 ]; then
    LINES=15
else
    LINES=$WALL_COUNT
fi

SELECTED_WALL=$(ls "$WALL_DIR" | fuzzel --dmenu -p "Select Wallpaper  " --lines "$LINES" --width 40 --font "Geist:weight=bold:size=10")

if [ -n "$SELECTED_WALL" ]; then
    bash "$THEME_SCRIPT" "$WALL_DIR/$SELECTED_WALL"
fi
