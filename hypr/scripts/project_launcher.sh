#!/bin/bash

DIR1="$HOME/Windows/Repositories/Android Repos"
DIR2="$HOME/Windows/Repositories"

SELECTED_NAME=$(find "$DIR1" "$DIR2" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | grep -v "^$DIR1$" | awk -F/ '{print $NF}' | fuzzel --dmenu -p "Project: " --lines=12 --font="Geist:weight=bold:size=10")

if [ -n "$SELECTED_NAME" ]; then
    PROJECT_PATH=$(find "$DIR1" "$DIR2" -mindepth 1 -maxdepth 1 -type d -name "$SELECTED_NAME" 2>/dev/null | head -n 1)
    
    EDITOR=$(echo -e "VS Code Insiders\nZed" | fuzzel --dmenu -p "Editor: " --lines=2 --font="Geist:weight=bold:size=10")
    
    case "$EDITOR" in
        "VS Code Insiders")
            code-insiders "$PROJECT_PATH" &
            notify-send -a "Waybar" "VS Code Insiders" "Opening $SELECTED_NAME"
            ;;
        "Zed")
            zeditor "$PROJECT_PATH" &
            notify-send -a "Waybar" "Zed" "Opening $SELECTED_NAME"
            ;;
    esac
fi