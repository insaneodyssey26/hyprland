#!/bin/bash

DIR1="$HOME/Projects"
DIR2="$HOME/Repos (Arch)"
DIR3="/mnt/windows/Repositories"

# Sort directories by most recently modified first
SELECTED_NAME=$(find "$DIR1" "$DIR2" "$DIR3" -mindepth 1 -maxdepth 1 -type d -not -name "node_modules" -printf '%T@ %p\n' 2>/dev/null | sort -rn | cut -d' ' -f2- | awk -F/ '{print $NF}' | awk '!seen[$0]++' | fuzzel --dmenu -p "Project: " --lines=12 --font="Geist:weight=bold:size=10")

if [ -n "$SELECTED_NAME" ]; then
    PROJECT_PATH=$(find "$DIR1" "$DIR2" "$DIR3" -mindepth 1 -maxdepth 1 -type d -name "$SELECTED_NAME" 2>/dev/null | head -n 1)
    
    EDITOR=$(echo -e "VS Code\nZed" | fuzzel --dmenu -p "Editor: " --lines=2 --font="Geist:weight=bold:size=10")
    
    case "$EDITOR" in
        "VS Code")
            code "$PROJECT_PATH" &
            notify-send -a "Waybar" "VS Code" "Opening $SELECTED_NAME"
            ;;
        "Zed")
            zeditor "$PROJECT_PATH" &
            notify-send -a "Waybar" "Zed" "Opening $SELECTED_NAME"
            ;;
    esac
fi
