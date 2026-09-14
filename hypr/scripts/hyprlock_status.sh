#!/usr/bin/env bash
BAT_STAT=$(cat /sys/class/power_supply/BAT1/status 2>/dev/null)
BAT_CAP=$(cat /sys/class/power_supply/BAT1/capacity 2>/dev/null)

if [ "$BAT_STAT" = "Charging" ]; then
    echo "󱐋  ${BAT_CAP}%"
else
    echo "  ${BAT_CAP}%"
fi
