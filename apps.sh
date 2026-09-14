#!/usr/bin/env bash

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info() {
    printf "${GREEN}==>${NC} %s\n" "$1"
}

step() {
    printf "${BLUE}::${NC} %s\n" "$1"
}

warn() {
    printf "${YELLOW}WARNING:${NC} %s\n" "$1"
}

error() {
    printf "${RED}ERROR:${NC} %s\n" "$1" >&2
}

WORKSPACE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. Install Applications
info "Installing Applications..."

PACMAN_APPS=(
    zed
)

AUR_APPS=(
    visual-studio-code-bin
    zen-browser-bin
    brave-origin-beta-bin
    jetbrains-toolbox
)

step "Installing official repo applications..."
for pkg in "${PACMAN_APPS[@]}"; do
    if ! pacman -Qi "$pkg" &>/dev/null; then
        sudo pacman -S --needed --noconfirm "$pkg"
    else
        echo "$pkg is already installed."
    fi
done

step "Installing AUR applications via paru..."
for pkg in "${AUR_APPS[@]}"; do
    if ! paru -Qi "$pkg" &>/dev/null; then
        paru -S --needed --noconfirm "$pkg"
    else
        echo "$pkg is already installed."
    fi
done

# 2. Deploy Zed Configuration
info "Deploying Zed configuration..."
if [ -d "$WORKSPACE/zed" ]; then
    mkdir -p "$HOME/.config"
    DEST_ZED="$HOME/.config/zed"
    
    if [ -d "$DEST_ZED" ]; then
        if [ -L "$DEST_ZED" ]; then
            rm "$DEST_ZED"
        else
            BACKUP_NAME="${DEST_ZED}.bak_$(date +%Y%m%d_%H%M%S)"
            mv "$DEST_ZED" "$BACKUP_NAME"
        fi
    fi
    ln -sf "$WORKSPACE/zed" "$DEST_ZED"
    step "Linked Zed config -> $DEST_ZED"
fi

# 3. Deploy VS Code Configuration
info "Deploying VS Code configuration..."
if [ -d "$WORKSPACE/Code/User" ]; then
    mkdir -p "$HOME/.config/Code/User"
    for file in "$WORKSPACE/Code/User"/*; do
        if [ -f "$file" ]; then
            fname=$(basename "$file")
            dest_file="$HOME/.config/Code/User/$fname"
            if [ -f "$dest_file" ]; then
                if [ -L "$dest_file" ]; then
                    rm "$dest_file"
                else
                    mv "$dest_file" "${dest_file}.bak_$(date +%Y%m%d_%H%M%S)"
                fi
            fi
            ln -sf "$file" "$dest_file"
            step "Linked VS Code $fname -> $dest_file"
        fi
    done
fi

info "All applications and configurations installed successfully!"
