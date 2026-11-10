#!/usr/bin/env bash

DIR="${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
mkdir -p "$DIR"

FILE="$DIR/Screenshot_$(date +'%Y-%m-%d_%H-%M-%S').png"
TMP_FULL="/tmp/aether_freeze_$$.png"

case "$1" in
    full)
        grim "$FILE" || exit 1
        wl-copy < "$FILE"
        ;;
    area)
        grim "$TMP_FULL" 2>/dev/null || exit 1

        quickshell ipc -p /home/masum/dotfiles/quickshell/shell.qml call freezeOverlay freeze "$TMP_FULL" 2>/dev/null
        sleep 0.05

        GEOM=$(slurp -b "#00000033" -c "#4fd6be" -B "#4fd6be22" -w 2 2>/dev/null)

        quickshell ipc -p /home/masum/dotfiles/quickshell/shell.qml call freezeOverlay unfreeze 2>/dev/null

        if [ -z "$GEOM" ]; then
            rm -f "$TMP_FULL"
            exit 0
        fi

        IFS=' ,' read -r C_X C_Y C_W C_H <<< "${GEOM/x/ }"
        if [ -n "$C_W" ] && [ -n "$C_H" ]; then
            ffmpeg -y -loglevel error -i "$TMP_FULL" -filter:v "crop=${C_W}:${C_H}:${C_X}:${C_Y}" "$FILE" 2>/dev/null
        else
            grim -g "$GEOM" "$FILE" 2>/dev/null
        fi

        rm -f "$TMP_FULL"

        if [ -f "$FILE" ]; then
            wl-copy < "$FILE"
            ACTION=$(notify-send -a "Screenshot" -i "$FILE" -t 5000 -A "edit=Edit in Satty" "Screenshot Captured" "Area copied to clipboard. Click to annotate.")
            if [ "$ACTION" = "edit" ] || [ "$ACTION" = "0" ] || [ "$ACTION" = "default" ]; then
                satty --filename "$FILE" --fullscreen
            fi
        fi
        ;;
    *)
        echo "Usage: $0 {full|area}"
        exit 1
        ;;
esac
