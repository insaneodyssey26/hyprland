#!/bin/bash
if pgrep -x waybar > /dev/null; then
    pkill -x waybar
    hyprctl eval 'hl.config({ general = { gaps_out = { top = 0, right = 0, bottom = 0, left = 0 } } })'
else
    hyprctl eval 'hl.config({ general = { gaps_out = { top = 8, right = 14, bottom = 14, left = 14 } } })'
    nohup waybar >/dev/null 2>&1 &
fi
