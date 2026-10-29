#!/usr/bin/env bash

LOCK_FILE="/tmp/hypr_zoom.last"
now=$(date +%s%N)
last=$(cat "$LOCK_FILE" 2>/dev/null || echo 0)

# 120ms debounce
if (( now - last < 120000000 )) && [ "$1" != "reset" ]; then
    exit 0
fi
echo "$now" > "$LOCK_FILE"

current=$(hyprctl getoption cursor:zoom_factor | grep "float:" | awk '{print $2}')
[ -z "$current" ] && current="1.000000"

step=0.25
min=1.00
max=2.50

case "$1" in
    in)
        new=$(awk -v c="$current" -v s="$step" -v m="$max" 'BEGIN { val=c+s; if (val>m) val=m; printf "%.2f", val }')
        ;;
    out)
        new=$(awk -v c="$current" -v s="$step" -v m="$min" 'BEGIN { val=c-s; if (val<m) val=m; printf "%.2f", val }')
        ;;
    reset)
        new="1.00"
        ;;
    *)
        exit 1
        ;;
esac

hyprctl eval "hl.config({ cursor = { zoom_factor = $new } })"
