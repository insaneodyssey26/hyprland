#!/usr/bin/env bash

layout=$(hyprctl getoption general:layout | grep "str:" | awk '{print $2}')
action=$1

if [[ "$layout" == "scrolling" ]]; then
    case "$action" in
        focus_left)  hyprctl dispatch "hl.dsp.layout('move -col')" ;;
        focus_right) hyprctl dispatch "hl.dsp.layout('move +col')" ;;
        move_left)   hyprctl dispatch "hl.dsp.layout('swapcol l')" ;;
        move_right)  hyprctl dispatch "hl.dsp.layout('swapcol r')" ;;
    esac
else
    case "$action" in
        focus_left)  hyprctl dispatch "hl.dsp.focus({direction='left'})" ;;
        focus_right) hyprctl dispatch "hl.dsp.focus({direction='right'})" ;;
        move_left)   hyprctl dispatch "hl.dsp.window.move({direction='left'})" ;;
        move_right)  hyprctl dispatch "hl.dsp.window.move({direction='right'})" ;;
    esac
fi
