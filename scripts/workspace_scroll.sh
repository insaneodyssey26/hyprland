#!/bin/bash
# Dedicated script for Waybar workspace scrolling
# Usage: ./workspace_scroll.sh [r+1|r-1]
hyprctl dispatch workspace "$1"
