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

# Ensure pacman is present and optimized
if ! command -v pacman >/dev/null 2>&1; then
    error "pacman package manager not found. This script requires an Arch Linux base."
fi

info "Configuring pacman..."
sudo sed -i \
  -e 's/^#Color/Color\nILoveCandy/' \
  -e 's/^Color$/Color\nILoveCandy/' \
  -e 's/^#VerbosePkgLists/VerbosePkgLists/' \
  -e 's/^#ParallelDownloads = .*/ParallelDownloads = 5/' \
  /etc/pacman.conf 2>/dev/null || true

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

OFFICIAL_PKGS="hyprland waybar swaync fuzzel hypridle hyprlock hyprpicker hyprsunset kitty foot zsh zsh-autosuggestions zsh-syntax-highlighting eza bat fzf fd ripgrep zoxide yazi nautilus loupe mpv btop asciiquarium cava gnome-calculator rnote satty fastfetch starship awww xdg-desktop-portal-hyprland xdg-desktop-portal-gtk polkit-kde-agent playerctl cliphist wl-clipboard xdg-user-dirs bluez bluez-utils networkmanager pipewire pipewire-pulse pipewire-alsa wireplumber pavucontrol qt5-wayland qt6-wayland brightnessctl noto-fonts noto-fonts-emoji ttf-nerd-fonts-symbols unzip zip power-profiles-daemon asusctl rog-control-center zram-generator"
AUR_PKGS="matugen-bin nautilus-open-any-terminal bemoji grimblast-git otf-geist maplemono-nf-unhinted wvkbd tty-clock"

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
CONFIG_FOLDERS="hypr kitty waybar swaync matugen foot fastfetch fish fuzzel gtk-3.0 reflector mpv cava"

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

# Deploy .bashrc
SRC_BASHRC="$WORKSPACE/.bashrc"
DEST_BASHRC="$HOME/.bashrc"
if [ -f "$SRC_BASHRC" ]; then
    if [ -f "$DEST_BASHRC" ]; then
        if [ -L "$DEST_BASHRC" ]; then
            rm "$DEST_BASHRC"
        else
            BACKUP_NAME="${DEST_BASHRC}.bak_$(date +%Y%m%d_%H%M%S)"
            mv "$DEST_BASHRC" "$BACKUP_NAME"
        fi
    fi
    ln -sf "$SRC_BASHRC" "$DEST_BASHRC"
fi

# Deploy .zprofile & .bash_profile (Auto-start Hyprland on login)
SRC_ZPROFILE="$WORKSPACE/.zprofile"
DEST_ZPROFILE="$HOME/.zprofile"
[ -f "$SRC_ZPROFILE" ] && ln -sf "$SRC_ZPROFILE" "$DEST_ZPROFILE"

SRC_BASHPROFILE="$WORKSPACE/.bash_profile"
DEST_BASHPROFILE="$HOME/.bash_profile"
[ -f "$SRC_BASHPROFILE" ] && ln -sf "$SRC_BASHPROFILE" "$DEST_BASHPROFILE"

# Deploy global gradle.properties
SRC_GRADLE="$WORKSPACE/gradle/gradle.properties"
DEST_GRADLE="$HOME/.gradle/gradle.properties"
if [ -f "$SRC_GRADLE" ]; then
    mkdir -p "$HOME/.gradle"
    ln -sf "$SRC_GRADLE" "$DEST_GRADLE"
fi

# 6. Initialize User Directories, Groups, ZRAM, & Systemd Services
info "Configuring user groups, ZRAM Swap, and Systemd services..."
xdg-user-dirs-update 2>/dev/null || true
sudo usermod -aG kvm "$USER" 2>/dev/null || true

# Configure ZRAM
if [ ! -f /etc/systemd/zram-generator.conf ]; then
    printf "[zram0]\nzram-size = ram / 2\ncompression-algorithm = zstd\nswap-priority = 100\nfs-type = swap\n" | sudo tee /etc/systemd/zram-generator.conf >/dev/null
    sudo systemctl daemon-reload
    sudo systemctl start /dev/zram0 2>/dev/null || true
fi

sudo systemctl enable --now NetworkManager.service 2>/dev/null || true
sudo systemctl enable --now bluetooth.service 2>/dev/null || true
sudo systemctl enable --now power-profiles-daemon.service 2>/dev/null || true
sudo systemctl enable --now asusd.service 2>/dev/null || true

# NVIDIA & System Power Management
if lspci | grep -iE 'vga|3d' | grep -iq nvidia; then
    printf "options nvidia NVreg_PreserveVideoMemoryAllocations=1\noptions nvidia_drm modeset=1 fbdev=1\n" | sudo tee /etc/modprobe.d/nvidia.conf >/dev/null
fi

# Prevent systemd from suspending on lid close (handled by Hyprland lock & DPMS)
sudo mkdir -p /etc/systemd/logind.conf.d
printf "[Login]\nHandleLidSwitch=ignore\nHandleLidSwitchExternalPower=ignore\nHandleLidSwitchDocked=ignore\n" | sudo tee /etc/systemd/logind.conf.d/lid.conf >/dev/null

# Deploy Limine Hook, Config & Wallpaper (if present)
if [ -f "$WORKSPACE/limine/99-limine.hook" ]; then
    sudo mkdir -p /etc/pacman.d/hooks
    sudo cp "$WORKSPACE/limine/99-limine.hook" /etc/pacman.d/hooks/99-limine.hook
fi
if [ -f "$WORKSPACE/limine/limine.conf" ] && [ -d /boot ]; then
    sudo cp "$WORKSPACE/limine/limine.conf" /boot/limine.conf 2>/dev/null || true
    sudo cp "$WORKSPACE/limine/limine-wallpaper.png" /boot/limine-wallpaper.png 2>/dev/null || true
fi
# Deploy Camera Privacy Udev Rule
if [ -f "$WORKSPACE/udev/99-camera-privacy.rules" ]; then
    sudo mkdir -p /etc/udev/rules.d
    sudo cp "$WORKSPACE/udev/99-camera-privacy.rules" /etc/udev/rules.d/99-camera-privacy.rules
    sudo udevadm control --reload-rules 2>/dev/null || true
    sudo udevadm trigger 2>/dev/null || true
fi

# Disable PAM Account Lockout (faillock)
if [ -f /etc/security/faillock.conf ]; then
    sudo sed -i 's/^#\? \?deny = .*/deny = 0/' /etc/security/faillock.conf 2>/dev/null || true
    sudo faillock --reset 2>/dev/null || true
fi

# 7. Initialize Theme, Assets & Wallpaper
info "Initializing assets, default wallpaper, and color palette..."
mkdir -p "$HOME/wallpapers"
[ -d "$WORKSPACE/assets" ] && ln -sf "$WORKSPACE/assets" "$HOME/.config/hypr/assets"
DEFAULT_WALLPAPER="$WORKSPACE/assets/default.png"
[ ! -f "$DEFAULT_WALLPAPER" ] && DEFAULT_WALLPAPER="$WORKSPACE/assets/desktop.png"
if [ -f "$DEFAULT_WALLPAPER" ]; then
    cp "$DEFAULT_WALLPAPER" "$HOME/wallpapers/default.png"
    [ -f "$WORKSPACE/assets/Buildings.png" ] && cp "$WORKSPACE/assets/Buildings.png" "$HOME/wallpapers/Buildings.png"
    ln -sf "$HOME/wallpapers/default.png" "$HOME/.current_wallpaper"
    matugen image "$HOME/wallpapers/default.png" -m dark --type scheme-fidelity --fallback-color '#6d6d6d' --source-color-index 0
fi

# 8. Set Default Shell
if [ "$SHELL" != "/usr/bin/zsh" ]; then
    info "Setting default shell to zsh..."
    chsh -s /usr/bin/zsh
fi

info "Setup completed successfully! Start your session with: Hyprland"
