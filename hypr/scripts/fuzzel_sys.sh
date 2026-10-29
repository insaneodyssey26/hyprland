#!/bin/bash

# Fast in-memory state evaluation (zero /tmp disk I/O)
spk=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | grep -q "MUTED" && echo "Muted" || echo "Active")
mic=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null | grep -q "MUTED" && echo "Muted" || echo "Active")
pgrep -x hyprsunset >/dev/null && sunset="Active" || sunset="Off"
nmcli -t -f WIFI g 2>/dev/null | grep -q "enabled" && wifi="Enabled" || wifi="Disabled"
rfkill list bluetooth 2>/dev/null | grep -qi "soft blocked: no" && bt="Enabled" || bt="Disabled"
grep -q "^ENABLED=yes" /etc/ufw/ufw.conf 2>/dev/null && fw="Enabled" || fw="Disabled"

cam="Disabled"
for d in /sys/bus/usb/devices/*; do
    if [ -f "$d/product" ] && grep -qiE "camera|webcam" "$d/product" 2>/dev/null; then
        [ "$(cat "$d/authorized" 2>/dev/null)" = "1" ] && { cam="Enabled"; break; }
    fi
done

layout_val=$(hyprctl getoption general:layout | grep "str:" | awk '{print $2}')
if [ "$layout_val" = "scrolling" ]; then
    layout_mode="Scrolling"
else
    layout_mode="Tiling"
fi

options="󰓃    Speaker: $spk\n    Mic: $mic\n󰖔    Night Light: $sunset\n    WiFi: $wifi\n    Bluetooth: $bt\n󰒓    Firewall: $fw\n󰄀    Camera: $cam\n󰕰    Layout: $layout_mode"
chosen=$(echo -e "$options" | fuzzel --dmenu -p "System Controls  " --lines=8 --font="Geist:weight=bold:size=10")

case "$chosen" in
    *Speaker*)
        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        spk_state=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q "MUTED" && echo "Muted" || echo "Unmuted")
        notify-send -a "Waybar" "Audio" "Speaker $spk_state" -t 2000
        ;;
    *Mic*)
        wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
        mic_state=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q "MUTED" && echo "Muted" || echo "Unmuted")
        notify-send -a "Waybar" "Privacy" "Microphone $mic_state" -t 2000
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
            (sudo -n ufw disable 2>/dev/null || pkexec ufw disable) && notify-send -a "Waybar" "Security" "Firewall Disabled" -t 2000
        else
            (sudo -n ufw enable 2>/dev/null || pkexec ufw enable) && notify-send -a "Waybar" "Security" "Firewall Enabled" -t 2000
        fi
        ;;
    *Camera*)
        bash ~/.config/hypr/scripts/toggle_camera.sh
        ;;
    *Layout*)
        bash ~/.config/hypr/scripts/toggle_scroll_mode.sh
        ;;
esac
