#!/bin/bash
if killall -9 wvkbd-mobintl 2>/dev/null; then
    exit 0
fi
/usr/bin/wvkbd-mobintl -L 250 >/dev/null 2>&1 &
disown
