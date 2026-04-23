#!/bin/bash

options="󰐥 Power Off\n󰜉 Reboot\n󰤄 Suspend\n󰍃 Log Out"

choice=$(echo -e "$options" | fuzzel --dmenu -p "System  " --lines=4 --font="Geist:weight=bold:size=10")

case "$choice" in
    "󰐥 Power Off") systemctl poweroff ;;
    "󰜉 Reboot") systemctl reboot ;;
    "󰤄 Suspend") systemctl suspend ;;
    "󰍃 Log Out") hyprctl dispatch exit ;;
esac
