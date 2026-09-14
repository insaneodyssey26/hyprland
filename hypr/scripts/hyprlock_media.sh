#!/usr/bin/env bash
STATUS=$(playerctl status 2>/dev/null)
if [ "$STATUS" = "Playing" ] || [ "$STATUS" = "Paused" ]; then
    TRACK=$(playerctl metadata --format '{{title}}  •  {{artist}}' 2>/dev/null | cut -c 1-50)
    if [ -n "$TRACK" ]; then
        echo "󰝚  $TRACK"
    fi
fi
