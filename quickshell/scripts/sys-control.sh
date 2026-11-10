#!/usr/bin/env bash

ACTION="$1"
EXTRA="$2"
TEMP_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/wlsunset_temp"

get_temp() {
    if [ -f "$TEMP_FILE" ]; then
        cat "$TEMP_FILE" 2>/dev/null || echo "3500"
    else
        echo "3500"
    fi
}

save_temp() {
    mkdir -p "$(dirname "$TEMP_FILE")" 2>/dev/null
    echo "$1" > "$TEMP_FILE"
}

case "$ACTION" in
    status)
        spk=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | grep -q "MUTED" && echo "false" || echo "true")
        mic=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null | grep -q "MUTED" && echo "false" || echo "true")
        
        if pgrep -x wlsunset >/dev/null || pgrep -x hyprsunset >/dev/null; then
            sunset="true"
        else
            sunset="false"
        fi

        nmcli -t -f WIFI g 2>/dev/null | grep -q "enabled" && wifi="true" || wifi="false"
        rfkill list bluetooth 2>/dev/null | grep -qi "soft blocked: no" && bt="true" || bt="false"
        grep -q "^ENABLED=yes" /etc/ufw/ufw.conf 2>/dev/null && fw="true" || fw="false"

        cam="false"
        for d in /sys/bus/usb/devices/*; do
            if [ -f "$d/product" ] && grep -qiE "camera|webcam" "$d/product" 2>/dev/null; then
                [ "$(cat "$d/authorized" 2>/dev/null)" = "1" ] && { cam="true"; break; }
            fi
        done

        curr_temp=$(get_temp)
        echo "{\"speaker\": $spk, \"mic\": $mic, \"sunset\": $sunset, \"wifi\": $wifi, \"bluetooth\": $bt, \"firewall\": $fw, \"camera\": $cam, \"sunset_temp\": $curr_temp}"
        ;;
    get_sunset_temp)
        get_temp
        ;;
    set_sunset_temp)
        new_temp="$EXTRA"
        if [ -n "$new_temp" ] && [ "$new_temp" -ge 1000 ] && [ "$new_temp" -le 6400 ]; then
            save_temp "$new_temp"
            if pgrep -x wlsunset >/dev/null || pgrep -x hyprsunset >/dev/null; then
                pkill -x wlsunset 2>/dev/null || pkill -x hyprsunset 2>/dev/null
                nohup wlsunset -T 6500 -t "$new_temp" -S 00:00 -s 00:00 >/dev/null 2>&1 &
            fi
            echo "$new_temp"
        fi
        ;;
    adjust_sunset_temp)
        delta="${EXTRA:- -250}"
        curr=$(get_temp)
        new_temp=$((curr + delta))
        if [ "$new_temp" -lt 1000 ]; then new_temp=1000; fi
        if [ "$new_temp" -gt 6400 ]; then new_temp=6400; fi
        save_temp "$new_temp"
        if pgrep -x wlsunset >/dev/null || pgrep -x hyprsunset >/dev/null; then
            pkill -x wlsunset 2>/dev/null || pkill -x hyprsunset 2>/dev/null
            nohup wlsunset -T 6500 -t "$new_temp" -S 00:00 -s 00:00 >/dev/null 2>&1 &
        fi
        echo "$new_temp"
        ;;
    toggle_speaker)
        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        ;;
    toggle_mic)
        wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
        ;;
    toggle_sunset)
        if pgrep -x wlsunset >/dev/null || pgrep -x hyprsunset >/dev/null; then
            pkill -x wlsunset 2>/dev/null || pkill -x hyprsunset 2>/dev/null
        else
            target_temp=$(get_temp)
            if command -v wlsunset >/dev/null; then
                nohup wlsunset -T 6500 -t "$target_temp" -S 00:00 -s 00:00 >/dev/null 2>&1 &
            else
                nohup hyprsunset --temperature "$target_temp" >/dev/null 2>&1 &
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
