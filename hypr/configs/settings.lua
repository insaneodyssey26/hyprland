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
        gaps_out = 8,
        border_size = 0,
        ["col.active_border"] = "rgba(00000000)",
        ["col.inactive_border"] = "rgba(00000000)",
        layout = "dwindle",
    },
    decoration = {
        rounding = 15,
        active_opacity = 1.0,
        inactive_opacity = 0.92,

        shadow = {
            enabled = true,
            range = 80,
            render_power = 4,
            color = "rgba(000000cc)",
            color_inactive = "rgba(00000066)",
        },

        blur = {
            enabled = true,
            size = 6,
            passes = 2,
            new_optimizations = true,
            ignore_opacity = true,
        },
    }
})

-- -----------------------------------------------------
-- LEGACY PARITY ANIMATIONS (Replicated from .conf)
-- -----------------------------------------------------
hl.config({ animations = { enabled = true } })

-- Replicating 'myBezier, 0.05, 0.9, 0.1, 1.05'
hl.curve("myBezier", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })

-- 1. Windows (Replicating exact .conf behavior)
hl.animation({ leaf = "windows",     enabled = true, speed = 6, bezier = "myBezier", style = "slide" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 6, bezier = "myBezier", style = "popin 80%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 5, bezier = "myBezier" })

-- 2. Fade
hl.animation({ leaf = "fade",        enabled = true, speed = 4, bezier = "default" })

-- 3. Workspaces
hl.animation({ leaf = "workspaces",  enabled = true, speed = 5, bezier = "myBezier", style = "slidefade 20%" })

-- 4. Premium Layer Extensions (Kept your requested blur/rules)
hl.config({
    layerrule = {
        "blur, fuzzel",
        "ignorealpha 0.5, fuzzel",
        "animation popin 10%, fuzzel",
        "shadow 1, fuzzel",
        "shadow_range 100, fuzzel",
        "shadow_render_power 4, fuzzel",
        "col.shadow_inactive " .. _G.color_primary_rgba .. ", fuzzel",
        
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
