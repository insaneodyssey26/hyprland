-- -----------------------------------------------------
-- INPUT & CURSOR
-- -----------------------------------------------------
hl.config({
    input = {
        kb_layout = "us",
        numlock_by_default = true,
        touchpad = {
            natural_scroll = true,
            disable_while_typing = true,
        },
        sensitivity = 0,
    },
    cursor = {
        no_hardware_cursors = true,
    }
})

-- -----------------------------------------------------
-- GENERAL & DECORATION
-- -----------------------------------------------------
hl.config({
    general = {
        gaps_in = 6,
        gaps_out = { top = 8, right = 14, bottom = 14, left = 14 },
        border_size = 0,
        ["col.active_border"] = "rgba(00000000)",
        ["col.inactive_border"] = "rgba(00000000)",
        layout = "scrolling",
    },
    scrolling = {
        column_width = 0.5,
        fullscreen_on_one_column = true,
    },
    decoration = {
        rounding = 15,
        active_opacity = 1.0,
        inactive_opacity = 0.95,

        shadow = {
            enabled = true,
            range = 80,
            render_power = 4,
            color = "rgba(000000df)",
            color_inactive = "rgba(00000080)",
        },

        blur = {
            enabled = true,
            size = 3,
            passes = 2,
            new_optimizations = true,
            ignore_opacity = true,
            noise = 0.0117,
            contrast = 1.3,
            brightness = 1.0,
            vibrancy = 0.2,
            vibrancy_darkness = 0.2,
        },
    }
})

-- -----------------------------------------------------
-- ANIMATIONS
-- -----------------------------------------------------
hl.config({ animations = { enabled = true } })

-- Replicating 'myBezier, 0.05, 0.9, 0.1, 1.05'
hl.curve("myBezier", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })
-- Smooth layout transition
hl.curve("smoothLinear", { type = "bezier", points = { {0.25, 1}, {0.5, 1} } })
-- Subtle spring curve
hl.curve("myBezierSoft", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.02} } })

-- 1. Windows
hl.animation({ leaf = "windows",     enabled = true, speed = 6, bezier = "myBezier", style = "slide" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 6, bezier = "myBezier", style = "popin 80%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 5, bezier = "myBezierSoft" })

-- 2. Fade
hl.animation({ leaf = "fade",        enabled = true, speed = 5, bezier = "default" })

-- 3. Workspaces
hl.animation({ leaf = "workspaces",  enabled = true, speed = 5, bezier = "myBezierSoft", style = "slidefade 20%" })

-- 4. Layer Extensions
hl.config({
    layerrule = {
        "blur, fuzzel",
        "ignorealpha 0.5, fuzzel",
        "animation popin 10%, fuzzel",
        "shadow 1, fuzzel",
        "shadow_range 100, fuzzel",
        "shadow_render_power 4, fuzzel",
        "col.shadow_inactive " .. _G.color_primary_rgba .. ", fuzzel",
        
        "blur, waybar",
        "ignorealpha 0.05, waybar",
        "blur, osk",
        "blur, wayboard",
        "ignorealpha 0.5, osk",
        "ignorealpha 0.5, wayboard",
        "animation slide bottom, wayboard",
        "blur, swaync",
        "ignorealpha 0.6, swaync"
    }
})

-- -----------------------------------------------------
-- LAYOUTS & MISC
-- -----------------------------------------------------
hl.config({
    dwindle = {
        preserve_split = true,
    },
    -- (Gestures moved to keywords for v0.55.0 stability)
    misc = {
        force_default_wallpaper = 0,
        mouse_move_enables_dpms = true,
        key_press_enables_dpms = true,
        vrr = 1,
    },
    debug = {
        vfr = true,
    }
})

return true
