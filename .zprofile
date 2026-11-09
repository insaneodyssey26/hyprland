if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" = 1 ] && [ -z "$NIRI_LAUNCHED" ]; then
    export NIRI_LAUNCHED=1
    exec niri-session
fi
