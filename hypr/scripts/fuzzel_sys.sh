#!/bin/bash

trap 'rm -f /tmp/spk_stat /tmp/mic_stat /tmp/sunset_stat /tmp/wifi_stat /tmp/bt_stat /tmp/fw_stat /tmp/cam_stat' EXIT

(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q "MUTED" && echo "Muted" || echo "Active") > /tmp/spk_stat &
(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q "MUTED" && echo "Muted" || echo "Active") > /tmp/mic_stat &
(pgrep hyprsunset > /dev/null && echo "Active" || echo "Off") > /tmp/sunset_stat &
(nmcli radio wifi | grep -q "enabled" && echo "Enabled" || echo "Disabled") > /tmp/wifi_stat &
(rfkill list bluetooth | grep -qi "soft blocked: no" && echo "Enabled" || echo "Disabled") > /tmp/bt_stat &
(sudo ufw status | grep -q "^Status: active" && echo "Enabled" || echo "Disabled") > /tmp/fw_stat &
(lsmod | grep -q uvcvideo && echo "Enabled" || echo "Disabled") > /tmp/cam_stat &

wait

spk=$(cat /tmp/spk_stat)
mic=$(cat /tmp/mic_stat)
sunset=$(cat /tmp/sunset_stat)
wifi=$(cat /tmp/wifi_stat)
bt=$(cat /tmp/bt_stat)
fw=$(cat /tmp/fw_stat)
cam=$(cat /tmp/cam_stat)

options="󰓃    Speaker: $spk\n    Mic: $mic\n󰖔    Night Light: $sunset\n    WiFi: $wifi\n    Bluetooth: $bt\n󰒓    Firewall: $fw\n󰄀    Camera: $cam"
chosen=$(echo -e "$options" | fuzzel --dmenu -p "System Controls   " --lines=7 --font="Geist:weight=bold:size=9")

case "$chosen" in
    *Speaker*)
        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        notify-send -a "Waybar" "Audio" "Speaker Toggled" -t 2000
        ;;
    *Mic*)
        wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
        notify-send -a "Waybar" "Privacy" "Microphone Toggled" -t 2000
        ;;
    *Night*)
        if [ "$sunset" = "Active" ]; then
            pkill hyprsunset
            notify-send -a "Waybar" "Display" "Night Light Off" -t 2000
        else
            hyprsunset --temperature 3500 &
            notify-send -a "Waybar" "Display" "Night Light On (3500K)" -t 2000
        fi
        ;;
    *WiFi*)
        if [ "$wifi" = "Enabled" ]; then
            nmcli radio wifi off; notify-send -a "Waybar" "Network" "WiFi Disabled" -t 2000
        else
            nmcli radio wifi on; notify-send -a "Waybar" "Network" "WiFi Enabled" -t 2000
        fi
        ;;
    *Bluetooth*)
        if [ "$bt" = "Enabled" ]; then
            rfkill block bluetooth; notify-send -a "Waybar" "Bluetooth" "Bluetooth Disabled" -t 2000
        else
            rfkill unblock bluetooth; bluetoothctl power on; notify-send -a "Waybar" "Bluetooth" "Bluetooth Enabled" -t 2000
        fi
        ;;
    *Firewall*)
        if [ "$fw" = "Enabled" ]; then
            sudo ufw disable; notify-send -a "Waybar" "Security" "Firewall Disabled" -t 2000
        else
            sudo ufw enable; notify-send -a "Waybar" "Security" "Firewall Enabled" -t 2000
        fi
        ;;
    *Camera*)
        if [ "$cam" = "Enabled" ]; then
            sudo modprobe -r uvcvideo; notify-send -a "Waybar" "Privacy" "Camera Hardware Disabled" -t 2000
        else
            sudo modprobe uvcvideo; notify-send -a "Waybar" "Privacy" "Camera Hardware Enabled" -t 2000
        fi
        ;;
esac
