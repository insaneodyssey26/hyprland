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
        border_size = 1,
        ["col.active_border"] = "rgba(82d5c833)",
        ["col.inactive_border"] = "rgba(00000000)",
        layout = "dwindle",
    },
    decoration = {
        rounding = 15,
        active_opacity = 1.0,
        inactive_opacity = 0.92,

        shadow = {
            enabled = true,
            range = 30,
            render_power = 3,
            color = "rgba(0e1513ee)",
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
-- ANIMATIONS
-- -----------------------------------------------------
hl.bezier("myBezier", 0.05, 0.9, 0.1, 1.05)

hl.config({
    animations = {
        enabled = true,
        animation = {
            "windows, 1, 6, myBezier, slide",
            "windowsOut, 1, 6, myBezier, popin 80%",
            "fade, 1, 4, default",
            "workspaces, 1, 5, myBezier, slidefade 20%",
        }
    }
})

-- -----------------------------------------------------
-- LAYOUTS & MISC
-- -----------------------------------------------------
hl.config({
    dwindle = {
        preserve_split = true,
    },
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
