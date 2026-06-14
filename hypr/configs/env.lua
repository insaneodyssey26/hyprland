-- -----------------------------------------------------
-- NVIDIA & WAYLAND ENVIRONMENT VARIABLES
-- -----------------------------------------------------

hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- Fix for Electron Apps (VS Code, Brave, Discord etc.)
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

-- Hardware Acceleration for Video
hl.env("NVD_BACKEND", "direct")

-- Cursor Configuration
hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Ice")
hl.env("HYPRCURSOR_SIZE", "24")

-- -----------------------------------------------------
-- APPS & CONSTANTS
-- -----------------------------------------------------
_G.terminal = "kitty"
_G.menu = "fuzzel"

return true
