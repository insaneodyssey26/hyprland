#!/bin/bash

# --- POWER MENU OPTIONS ---
# Order: Lock, Power Off, Reboot, Suspend, Log Out
options="󰌾    Lock\n󰐥    Power Off\n󰜉    Reboot\n󰤄    Suspend\n󰍃    Log Out"

# --- DISPLAY MENU ---
choice=$(echo -e "$options" | fuzzel --dmenu -p "System  " --lines=5 --font="Geist:weight=bold:size=10")

# --- ACTIONS ---
case "$choice" in
    *Lock*) loginctl lock-session ;;
    *Off*) systemctl poweroff ;;
    *Reboot*) systemctl reboot ;;
    *Suspend*) systemctl suspend ;;
    *Out*) loginctl terminate-user $USER ;;
esac
