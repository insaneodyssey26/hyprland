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

OFFICIAL_PKGS="hyprland waybar swaync fuzzel hypridle hyprlock hyprpicker hyprsunset kitty foot zsh zsh-autosuggestions zsh-syntax-highlighting eza bat fzf zoxide yazi nautilus gnome-calculator rnote satty fastfetch starship awww xdg-desktop-portal-hyprland xdg-desktop-portal-gtk polkit-kde-agent playerctl cliphist wl-clipboard xdg-user-dirs bluez bluez-utils networkmanager pipewire pipewire-pulse pipewire-alsa wireplumber pavucontrol qt5-wayland qt6-wayland brightnessctl noto-fonts-emoji unzip zip power-profiles-daemon"
AUR_PKGS="matugen-bin nautilus-open-any-terminal brave-origin-beta-bin bemoji grimblast-git otf-geist maplemono-nf-unhinted wvkbd"

# Detect NVIDIA GPU and append appropriate drivers
if lspci | grep -iE 'vga|3d' | grep -iq nvidia; then
    info "NVIDIA GPU detected. Adding driver packages..."
    OFFICIAL_PKGS="$OFFICIAL_PKGS nvidia-open-dkms nvidia-utils nvidia-prime libva-nvidia-driver egl-wayland"
fi

info "Installing official repository packages..."
sudo pacman -S --needed --noconfirm $OFFICIAL_PKGS

info "Installing AUR packages..."
paru -S --needed --noconfirm $AUR_PKGS

# 5. Configuration Deployment (Symlinking)
info "Deploying configurations..."
mkdir -p "$HOME/.config" "$HOME/.local/share/icons" "$HOME/.icons/default" "$HOME/Pictures/Screenshots" "$HOME/wallpapers" "$HOME/.config/zsh" "$HOME/.config/cava/themes"

# Deploy cursor theme if present in repo
if [ -d "$WORKSPACE/icons/Moga-Black" ]; then
    info "Installing Moga-Black cursor theme..."
    cp -r "$WORKSPACE/icons/Moga-Black" "$HOME/.local/share/icons/"
    printf "[Icon Theme]\nInherits=Moga-Black\n" > "$HOME/.icons/default/index.theme"
fi

# List of folders to deploy
CONFIG_FOLDERS="hypr kitty waybar swaync matugen foot fastfetch fish fuzzel gtk-3.0 reflector"

for folder in $CONFIG_FOLDERS; do
    SRC="$WORKSPACE/$folder"
    DEST="$HOME/.config/$folder"
    
    if [ ! -d "$SRC" ]; then
        info "Warning: Workspace source folder '$SRC' does not exist. Skipping."
        continue
    fi
    
    if [ -d "$DEST" ]; then
        if [ -L "$DEST" ]; then
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
            mv "$DEST_STARSHIP" "$BACKUP_NAME"
        fi
    fi
    ln -sf "$SRC_STARSHIP" "$DEST_STARSHIP"
fi

# Deploy .zshrc
SRC_ZSHRC="$WORKSPACE/.zshrc"
DEST_ZSHRC="$HOME/.zshrc"
if [ -f "$SRC_ZSHRC" ]; then
    if [ -f "$DEST_ZSHRC" ]; then
        if [ -L "$DEST_ZSHRC" ]; then
            rm "$DEST_ZSHRC"
        else
            BACKUP_NAME="${DEST_ZSHRC}.bak_$(date +%Y%m%d_%H%M%S)"
            mv "$DEST_ZSHRC" "$BACKUP_NAME"
        fi
    fi
    ln -sf "$SRC_ZSHRC" "$DEST_ZSHRC"
fi

# 6. Initialize User Directories & Systemd Services
info "Enabling systemd services..."
xdg-user-dirs-update 2>/dev/null || true
sudo systemctl enable --now NetworkManager.service 2>/dev/null || true
sudo systemctl enable --now bluetooth.service 2>/dev/null || true
sudo systemctl enable --now power-profiles-daemon.service 2>/dev/null || true

# 7. Initialize Theme & Wallpaper
info "Initializing default wallpaper and color palette..."
DEFAULT_WALLPAPER="$WORKSPACE/assets/desktop.png"
if [ -f "$DEFAULT_WALLPAPER" ]; then
    cp "$DEFAULT_WALLPAPER" "$HOME/wallpapers/default.png"
    ln -sf "$HOME/wallpapers/default.png" "$HOME/.current_wallpaper"
    matugen image "$HOME/wallpapers/default.png" -m dark --type scheme-fidelity --fallback-color '#6d6d6d' --source-color-index 0
fi

# 8. Set Default Shell
if [ "$SHELL" != "/usr/bin/zsh" ]; then
    info "Setting default shell to zsh..."
    chsh -s /usr/bin/zsh
fi

info "Setup completed successfully! Start your session with: Hyprland"
