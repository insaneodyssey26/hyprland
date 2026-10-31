#!/usr/bin/env bash

THEME_SCRIPT="$HOME/.config/hypr/scripts/theme.sh"
WALL_DIR="$HOME/wallpapers"

RANDOM_WALL=$(ls "$WALL_DIR" | shuf -n 1)
bash "$THEME_SCRIPT" "$WALL_DIR/$RANDOM_WALL"
