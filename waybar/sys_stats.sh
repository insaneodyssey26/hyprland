#!/bin/bash

CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
RAM_USAGE=$(free -m | awk '/Mem:/ { printf "%d / %d MB (%.1f%%)", $3, $2, $3*100/$2 }')
FAN=$(cat /sys/class/hwmon/hwmon*/fan1_input 2>/dev/null | xargs | awk '{if($2) print $1" / "$2" RPM"; else if($1) print $1" RPM"; else print "0 RPM"}')
read -r GPU GPU_TEMP <<< $(nvidia-smi --query-gpu=utilization.gpu,temperature.gpu --format=csv,noheader,nounits 2>/dev/null | tr -d ',' | xargs)
DISK=$(df -h / | awk 'NR==2 {print $3 " / " $2 " (" $5 ")"}')
CPU_CLOCK=$(cat /proc/cpuinfo | awk '/^cpu MHz/ {printf "%.2f GHz", $4/1000; exit}')
TOP_RAM=$(ps axch -o cmd,%mem --sort=-%mem | head -n 1 | awk '{print $1 " (" $2 "%)"}')
IP=$(ip addr show | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | cut -d/ -f1 | head -n 1)

MESSAGE="  <b>CPU Usage:</b>   ${CPU_USAGE:-0}%
󰓅  <b>CPU Clock:</b>   $CPU_CLOCK
󰍛  <b>RAM Usage:</b>   $RAM_USAGE
󰍛  <b>Top RAM:</b>     $TOP_RAM
󰈐  <b>Fan Speed:</b>   $FAN
󰢮  <b>GPU Usage:</b>   ${GPU:-0}%
  <b>GPU Temp:</b>    ${GPU_TEMP:-0}° C
󰋊  <b>Disk (/):</b>    $DISK
󰖩  <b>Local IP:</b>    $IP"

notify-send -a "Waybar" "Hardware Status" "$MESSAGE"
