#!/usr/bin/env bash

DIR="${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
mkdir -p "$DIR"

FILE="$DIR/Screenshot_$(date +'%Y-%m-%d_%H-%M-%S').png"

case "$1" in
    full)
        grim "$FILE" || exit 1
        wl-copy < "$FILE"
        ;;
    area)
        GEOM=$(slurp)
        [ -z "$GEOM" ] && exit 0
        grim -g "$GEOM" "$FILE" || exit 1
        wl-copy < "$FILE"
        
        # Send interactive notification (auto-dismisses after 5 seconds)
        ACTION=$(notify-send \
            -a "Screenshot" \
            -i "$FILE" \
            -t 5000 \
            -A "edit=Open in Editor" \
            "Screenshot Captured" \
            "Area copied to clipboard. Click to open.")

        if [ "$ACTION" = "edit" ] || [ "$ACTION" = "0" ] || [ "$ACTION" = "default" ]; then
            satty --filename "$FILE" --fullscreen
        fi
        ;;
    *)
        echo "Usage: $0 {full|area}"
        exit 1
        ;;
esac
