#!/bin/bash

PROCESS=$(ps x -o pid,%mem,comm --sort=-%mem | awk 'NR>1 {print $1 "   " $2 "%   " $3}' | head -n 50 | fuzzel --dmenu -p "Kill  " --lines=12 --font="Geist:weight=bold:size=10")

if [ -n "$PROCESS" ]; then
    PID=$(echo "$PROCESS" | awk '{print $1}')
    NAME=$(echo "$PROCESS" | awk '{print $3}')
    
    kill -9 "$PID"
    
    # Send a clean Waybar notification confirming the kill
    notify-send -a "Waybar" "💀 Process Killed" "Terminated $NAME (PID: $PID)"
fi
