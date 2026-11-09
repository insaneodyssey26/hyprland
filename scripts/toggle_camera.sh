#!/bin/bash

get_cam_devs() {
    local devs=()
    for dev in /sys/bus/usb/devices/*; do
        if [ -f "$dev/product" ] && grep -qiE "camera|webcam" "$dev/product" 2>/dev/null; then
            devs+=("$dev")
        fi
    done
    echo "${devs[@]}"
}

get_status() {
    local devs=($(get_cam_devs))
    if [ ${#devs[@]} -eq 0 ]; then
        echo "Disabled"
        return
    fi

    for dev in "${devs[@]}"; do
        if [ -f "$dev/authorized" ] && [ "$(cat "$dev/authorized" 2>/dev/null)" = "1" ]; then
            echo "Enabled"
            return
        fi
    done
    echo "Disabled"
}

set_camera_state() {
    local target_val="$1"
    local devs=($(get_cam_devs))
    for dev in "${devs[@]}"; do
        if [ -f "$dev/authorized" ]; then
            if ! echo "$target_val" > "$dev/authorized" 2>/dev/null; then
                echo "$target_val" | sudo -n tee "$dev/authorized" >/dev/null 2>&1 || \
                echo "$target_val" | pkexec tee "$dev/authorized" >/dev/null 2>&1
            fi
        fi
    done
}

toggle_camera() {
    local devs=($(get_cam_devs))
    if [ ${#devs[@]} -eq 0 ]; then
        notify-send -a "Waybar" "Privacy" "No USB camera detected" -t 2000
        return
    fi

    local current_status=$(get_status)
    if [ "$current_status" = "Disabled" ]; then
        set_camera_state 1
        notify-send -a "Waybar" "Privacy" "Camera Enabled" -t 2000
    else
        set_camera_state 0
        notify-send -a "Waybar" "Privacy" "Camera Disabled" -t 2000
    fi
}

case "$1" in
    --status)
        get_status
        ;;
    --off)
        set_camera_state 0
        ;;
    --on)
        set_camera_state 1
        ;;
    *)
        toggle_camera
        ;;
esac
