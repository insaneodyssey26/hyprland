#!/bin/bash

options="󰌾    Lock\n󰐥    Power Off\n󰜉    Reboot\n󰍃    Log Out"
choice=$(echo -e "$options" | fuzzel --dmenu -p "System  " --lines=4 --font="Geist:weight=bold:size=10")

case "$choice" in
    *Lock*) loginctl lock-session ;;
    *Off*) systemctl poweroff ;;
    *Reboot*) systemctl reboot ;;
    *Out*) loginctl terminate-user "$USER" ;;
esac

