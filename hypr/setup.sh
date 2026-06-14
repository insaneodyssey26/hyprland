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
PACKAGES="hyprland waybar-git swaync fuzzel hypridle-git hyprlock matugen-bin kitty foot fish eza bat fzf zoxide yazi nautilus brave-origin-beta-bin gnome-calculator rnote bemoji-git grimblast-git satty fastfetch starship awww xdg-desktop-portal-hyprland xdg-desktop-portal-gtk polkit-kde-agent playerctl cliphist wl-clipboard xdg-user-dirs bluez bluez-utils networkmanager pipewire wireplumber qt5-wayland qt6-wayland brightnessctl"

info "Installing packages (this may take some time)..."
paru -S --needed $PACKAGES

# 5. Configuration Deployment (Symlinking)
info "Deploying configurations..."
mkdir -p "$HOME/.config"

# List of folders to deploy
CONFIG_FOLDERS="hypr kitty waybar swaync matugen foot fastfetch fish fuzzel gtk-3.0 reflector"

for folder in $CONFIG_FOLDERS; do
    SRC="$WORKSPACE/$folder"
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

# Deploy starship.toml file
SRC_STARSHIP="$WORKSPACE/starship.toml"
DEST_STARSHIP="$HOME/.config/starship.toml"
if [ -f "$SRC_STARSHIP" ]; then
    if [ -f "$DEST_STARSHIP" ]; then
        if [ -L "$DEST_STARSHIP" ]; then
            rm "$DEST_STARSHIP"
        else
            BACKUP_NAME="${DEST_STARSHIP}.bak_$(date +%Y%m%d_%H%M%S)"
            info "Backing up existing starship.toml to '$BACKUP_NAME'..."
            mv "$DEST_STARSHIP" "$BACKUP_NAME"
        fi
    fi
    info "Symlinking 'starship.toml' to '$DEST_STARSHIP'..."
    ln -sf "$SRC_STARSHIP" "$DEST_STARSHIP"
fi

# 6. Initialize Theme Generation
info "Generating default theme using Matugen..."
DEFAULT_WALLPAPER="$WORKSPACE/assets/arch_logo.png"
if [ -f "$DEFAULT_WALLPAPER" ]; then
    matugen image "$DEFAULT_WALLPAPER" -m dark --type scheme-fidelity --fallback-color '#6d6d6d' --source-color-index 0
else
    info "Warning: Default wallpaper asset not found. Matugen initial colors skipped."
fi

# 7. Set Default Shell
if [ "$SHELL" != "/usr/bin/fish" ]; then
    info "Setting default shell to fish..."
    # chsh will run interactively to prompt for password
    chsh -s /usr/bin/fish
fi

info "Installation and setup completed successfully."
info "You can now start your desktop environment by typing: Hyprland"
