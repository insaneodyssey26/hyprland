#!/bin/bash
fans=$(cat /sys/devices/platform/asus-nb-wmi/hwmon/hwmon*/fan1_input 2>/dev/null | head -n 1)
echo "${fans:-0}"
