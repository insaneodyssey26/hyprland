#!/usr/bin/env bash

ACTION="$1"

case "$ACTION" in
    status)
        spk=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | grep -q "MUTED" && echo "false" || echo "true")
        mic=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null | grep -q "MUTED" && echo "false" || echo "true")
        pgrep -x wlsunset >/dev/null || pgrep -x hyprsunset >/dev/null && sunset="true" || sunset="false"
        nmcli -t -f WIFI g 2>/dev/null | grep -q "enabled" && wifi="true" || wifi="false"
        rfkill list bluetooth 2>/dev/null | grep -qi "soft blocked: no" && bt="true" || bt="false"
        grep -q "^ENABLED=yes" /etc/ufw/ufw.conf 2>/dev/null && fw="true" || fw="false"

        cam="false"
        for d in /sys/bus/usb/devices/*; do
            if [ -f "$d/product" ] && grep -qiE "camera|webcam" "$d/product" 2>/dev/null; then
                [ "$(cat "$d/authorized" 2>/dev/null)" = "1" ] && { cam="true"; break; }
            fi
        done

        echo "{\"speaker\": $spk, \"mic\": $mic, \"sunset\": $sunset, \"wifi\": $wifi, \"bluetooth\": $bt, \"firewall\": $fw, \"camera\": $cam}"
        ;;
    toggle_speaker)
        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        ;;
    toggle_mic)
        wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
        ;;
    toggle_sunset)
        if pgrep -x wlsunset >/dev/null || pgrep -x hyprsunset >/dev/null; then
            pkill wlsunset 2>/dev/null || pkill hyprsunset 2>/dev/null
        else
            if command -v wlsunset >/dev/null; then
                wlsunset -t 3500 &
            else
                hyprsunset --temperature 3500 &
            fi
        fi
        ;;
    toggle_wifi)
        if nmcli -t -f WIFI g 2>/dev/null | grep -q "enabled"; then
            nmcli radio wifi off
        else
            nmcli radio wifi on
        fi
        ;;
    toggle_bluetooth)
        if rfkill list bluetooth 2>/dev/null | grep -qi "soft blocked: no"; then
            rfkill block bluetooth
        else
            rfkill unblock bluetooth
            bluetoothctl power on 2>/dev/null || true
        fi
        ;;
    toggle_firewall)
        if grep -q "^ENABLED=yes" /etc/ufw/ufw.conf 2>/dev/null; then
            sudo -n ufw disable 2>/dev/null || pkexec ufw disable
        else
            sudo -n ufw enable 2>/dev/null || pkexec ufw enable
        fi
        ;;
    toggle_camera)
        bash /home/masum/dotfiles/scripts/toggle_camera.sh
        ;;
esac
