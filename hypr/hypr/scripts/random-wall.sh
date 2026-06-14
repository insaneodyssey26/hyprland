#!/usr/bin/env bash

THEME_SCRIPT="$HOME/.config/hypr/scripts/theme.sh"
WALL_DIR="$HOME/wallpapers"

# Pick a random image
RANDOM_WALL=$(ls "$WALL_DIR" | shuf -n 1)

# Apply theme
bash "$THEME_SCRIPT" "$WALL_DIR/$RANDOM_WALL"
