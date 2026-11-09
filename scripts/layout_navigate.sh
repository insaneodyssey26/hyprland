#!/usr/bin/env bash

layout=$(hyprctl getoption general:layout | grep "str:" | awk '{print $2}')
action=$1

toggle_size_or_center() {
    # Check width of focused window and monitor width
    local curr_width mon_width threshold
    curr_width=$(hyprctl activewindow -j 2>/dev/null | grep -o '"size": \[[0-9]*' | awk -F'[' '{print $2}')
    mon_width=$(hyprctl monitors -j 2>/dev/null | grep -o '"width": [0-9]*' | head -n 1 | awk '{print $2}')
    
    # If window takes >= 75% of monitor width, shrink/revert it back to default column width
    threshold=$(( (mon_width * 3) / 4 ))
    if [ -n "$curr_width" ] && [ "$curr_width" -gt "$threshold" ]; then
        hyprctl dispatch "hl.dsp.layout('colresize -conf')"
    else
        hyprctl dispatch "hl.dsp.layout('fit active')"
    fi
}

if [[ "$layout" == "scrolling" ]]; then
    # Get number of windows currently open on the active workspace
    window_count=$(hyprctl activeworkspace -j 2>/dev/null | grep -o '"windows": [0-9]*' | awk '{print $2}')
    window_count=${window_count:-0}

    # If only 1 window is open, keep navigation from sliding it off-screen
    if [ "$window_count" -le 1 ]; then
        case "$action" in
            focus_left|focus_right)
                hyprctl dispatch "hl.dsp.layout('fit active')" >/dev/null 2>&1
                exit 0
                ;;
        esac
    fi

    case "$action" in
        focus_left)   hyprctl dispatch "hl.dsp.layout('move -col')" ;;
        focus_right)  hyprctl dispatch "hl.dsp.layout('move +col')" ;;
        move_left)    hyprctl dispatch "hl.dsp.layout('swapcol l')" ;;
        move_right)   hyprctl dispatch "hl.dsp.layout('swapcol r')" ;;
        expand)       hyprctl dispatch "hl.dsp.layout('colresize +conf')" ;;
        shrink)       hyprctl dispatch "hl.dsp.layout('colresize -conf')" ;;
        center)       toggle_size_or_center ;;
    esac
else
    case "$action" in
        focus_left)  hyprctl dispatch "hl.dsp.focus({direction='left'})" ;;
        focus_right) hyprctl dispatch "hl.dsp.focus({direction='right'})" ;;
        move_left)   hyprctl dispatch "hl.dsp.window.move({direction='left'})" ;;
        move_right)  hyprctl dispatch "hl.dsp.window.move({direction='right'})" ;;
    esac
fi
