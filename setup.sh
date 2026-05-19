#!/bin/sh
# -----------------------------------------------------
# End-to-End Desktop Environment Installer & Setup
# -----------------------------------------------------
set -e

# Setup clean output formatting
info() {
    printf "\r\033[2K\033[0;34m[INFO]\033[0m %s\n" "$1"
}

error() {
    printf "\r\033[2K\033[0;31m[ERROR]\033[0m %s\n" "$1" >&2
    exit 1
}

# 1. Environment & Pre-requisite Checks
info "Running system checks..."
if [ "$(id -u)" -eq 0 ]; then
    error "Do not run this script as root/sudo directly. It will request elevation when needed."
fi

# Ensure pacman is present
if ! command -v pacman >/dev/null 2>&1; then
    error "pacman package manager not found. This script requires an Arch Linux base."
fi

# Ensure git is installed
if ! command -v git >/dev/null 2>&1; then
    info "git not found. Installing git..."
    sudo pacman -S --needed --noconfirm git
fi

# 2. Clone configuration repository if running as a bootstrap script
WORKSPACE="$HOME/hyprland"
REPO_URL="https://github.com/insaneodyssey26/hyprland"

if [ ! -d "$WORKSPACE" ]; then
    info "Cloning configuration repository from $REPO_URL..."
    git clone "$REPO_URL" "$WORKSPACE"
else
    info "Configuration repository already exists at $WORKSPACE"
fi

# Ensure makepkg is present (base-devel)
if ! command -v makepkg >/dev/null 2>&1; then
    info "Installing base-devel package group..."
    sudo pacman -S --needed --noconfirm base-devel
fi

# 3. AUR Helper (paru) Installation
if ! command -v paru >/dev/null 2>&1; then
    info "Installing AUR helper (paru)..."
    sudo pacman -S --needed --noconfirm base-devel git
    
    BUILD_DIR=$(mktemp -d)
    git clone https://aur.archlinux.org/paru.git "$BUILD_DIR"
    (
        cd "$BUILD_DIR" || exit 1
        makepkg -si --noconfirm
    )
    rm -rf "$BUILD_DIR"
else
    info "AUR helper (paru) is already installed."
fi

# 4. Package Installation
# Exact package names currently running on the system
PACKAGES="hyprland waybar-git swaync fuzzel hypridle-git hyprlock matugen-bin kitty foot fish eza bat fzf zoxide yazi nautilus brave-origin-beta-bin qalculate-gtk rnote bemoji-git grimblast-git satty"

info "Installing packages (this may take some time)..."
paru -S --needed --noconfirm $PACKAGES

# 5. Configuration Deployment (Symlinking)
info "Deploying configurations..."
mkdir -p "$HOME/.config"

# List of folders to deploy
CONFIG_FOLDERS="hypr kitty waybar swaync matugen foot"

for folder in $CONFIG_FOLDERS; do
    SRC="$HOME/hyprland/$folder"
    DEST="$HOME/.config/$folder"
    
    if [ ! -d "$SRC" ]; then
        info "Warning: Workspace source folder '$SRC' does not exist. Skipping."
        continue
    fi
    
    # Backup existing configuration if it is a physical folder and not a symlink
    if [ -d "$DEST" ]; then
        if [ -L "$DEST" ]; then
            info "Removing existing symlink for '$folder'..."
            rm "$DEST"
        else
            BACKUP_NAME="${DEST}.bak_$(date +%Y%m%d_%H%M%S)"
            info "Backing up existing directory to '$BACKUP_NAME'..."
            mv "$DEST" "$BACKUP_NAME"
        fi
    fi
    
    info "Symlinking '$folder' to '$DEST'..."
    ln -sf "$SRC" "$DEST"
done

# 6. Initialize Theme Generation
info "Generating default theme using Matugen..."
DEFAULT_WALLPAPER="$HOME/hyprland/assets/arch.png"
if [ -f "$DEFAULT_WALLPAPER" ]; then
    matugen image "$DEFAULT_WALLPAPER" -m dark --type scheme-fidelity --fallback-color '#6d6d6d' --source-color-index 0
else
    info "Warning: Default wallpaper asset not found. Matugen initial colors skipped."
fi

info "Installation and setup completed successfully."
info "You can now start your desktop environment by typing: Hyprland"
