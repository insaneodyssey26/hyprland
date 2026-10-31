-- Nvidia & Wayland environment
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- Electron ozone support
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

-- Video acceleration
hl.env("NVD_BACKEND", "direct")

hl.env("XCURSOR_THEME", "Moga-Black")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_THEME", "Moga-Black")
hl.env("HYPRCURSOR_SIZE", "24")

_G.terminal = "kitty"
_G.menu = "fuzzel"

return true
