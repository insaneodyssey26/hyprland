#!/usr/bin/env bash
# ==============================================================================
# SAFE NESTED NIRI TEST RUNNER (Leaves Hyprland completely unaffected)
# ==============================================================================

export WLR_BACKENDS=wayland
export NIRI_CONFIG="/home/masum/.config/niri/config.kdl"

echo "Launching Niri in a nested window on current Hyprland desktop..."
echo "Press Mod+Shift+M or close the window to exit."

# Run in an isolated session namespace
exec niri
