#!/usr/bin/env bash

THEME_SCRIPT="$HOME/.config/scripts/theme.sh"
[ -f "$THEME_SCRIPT" ] || THEME_SCRIPT="/home/masum/dotfiles/scripts/theme.sh"
WALL_DIR="$HOME/wallpapers"

RANDOM_WALL=$(ls "$WALL_DIR" | shuf -n 1)
bash "$THEME_SCRIPT" "$WALL_DIR/$RANDOM_WALL"
