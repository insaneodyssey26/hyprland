#!/usr/bin/env bash

if command -v wvkbd-mobintl &> /dev/null; then
    BIN="wvkbd-mobintl"
elif command -v wvkbd &> /dev/null; then
    BIN="wvkbd"
else
    notify-send "OSK Error" "No wvkbd binary found."
    exit 1
fi

COLOR_FILE="$HOME/.config/waybar/colors.css"

get_color() {
    if [ -f "$COLOR_FILE" ]; then
        res=$(grep "@define-color $1" "$COLOR_FILE" | awk '{print $3}' | tr -d '#;')
        echo "${res:-$2}"
    else
        echo "$2"
    fi
}

BG=$(get_color "surface" "141218")
ACCENT=$(get_color "primary" "d1bcfd")
TEXT=$(get_color "on-primary" "ffffff") 

# 3. Toggle Logic
if pidof "$BIN" > /dev/null; then
    pkill "$BIN"
else
    $BIN -L 200 \
        -R 10 \
        --bg "$BG" \
        --fg "$ACCENT" \
        --text "$TEXT" \
        --alpha 220 &
fi
