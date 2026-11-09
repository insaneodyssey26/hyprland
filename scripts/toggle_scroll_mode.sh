#!/usr/bin/env bash

current_layout=$(hyprctl getoption general:layout | grep "str:" | awk '{print $2}')

if [[ "$current_layout" == "dwindle" ]]; then
    hyprctl eval "hl.config({ general = { layout = 'scrolling' } })"
    hyprctl eval "hl.animation({ leaf = 'windows', enabled = true, speed = 6, bezier = 'myBezierSoft', style = 'slide' })"
    notify-send -a "System" "Layout Engine" "Scrolling mode activated" -t 1500
else
    hyprctl eval "hl.config({ general = { layout = 'dwindle' } })"
    hyprctl eval "hl.animation({ leaf = 'windows', enabled = true, speed = 6, bezier = 'myBezier', style = 'slide' })"
    notify-send -a "System" "Layout Engine" "Tiling mode activated" -t 1500
fi
