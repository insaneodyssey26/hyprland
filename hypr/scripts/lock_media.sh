#!/bin/bash
status=$(playerctl status 2>/dev/null)
if [ "$status" = "Playing" ]; then
    title=$(playerctl metadata --format '{{title}}' 2>/dev/null | cut -c 1-35)
    artist=$(playerctl metadata --format '{{artist}}' 2>/dev/null | cut -c 1-25)
    if [ -n "$artist" ] && [ -n "$title" ]; then
        echo "󰝚   $title   •   $artist"
    elif [ -n "$title" ]; then
        echo "󰝚   $title"
    fi
elif [ "$status" = "Paused" ]; then
    title=$(playerctl metadata --format '{{title}}' 2>/dev/null | cut -c 1-35)
    artist=$(playerctl metadata --format '{{artist}}' 2>/dev/null | cut -c 1-25)
    if [ -n "$artist" ] && [ -n "$title" ]; then
        echo "󰝛   $title   •   $artist"
    elif [ -n "$title" ]; then
        echo "󰝛   $title"
    fi
fi
