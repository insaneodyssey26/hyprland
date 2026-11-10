#!/usr/bin/env bash
pgrep -x hyprlock >/dev/null && exit 0
exec /usr/bin/hyprlock --config /home/masum/dotfiles/hyprlock/hyprlock.conf
