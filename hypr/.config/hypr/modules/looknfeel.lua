-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
    general = {
        gaps_in  = 0,
        gaps_out = 0,

        border_size = 0,

        col = {
            active_border   = { colors = {"rgba(4F5B58aa)", "rgba(495156aa)"}, angle = 45 },
            -- active_border = "rgba(D3C6AAaa)",
            inactive_border = "rgba(1E2326aa)",
        },

        -- Set to true to enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = false,

        -- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
        allow_tearing = false,

        layout = "dwindle",
    },

    decoration = {
        rounding       = 0,
        rounding_power = 2,

        -- Change transparency of focused and unfocused windows
        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = false,
            range        = 20,
            render_power = 3,
            color        = 0xee1a1a1a,
        },

        blur = {
            enabled   = true,
            size      = 8,
            passes    = 3,
            new_optimizations = true,
            ignore_opacity = true,
        },
    },

    animations = {
        enabled = false,
    },

    cursor = {
        no_hardware_cursors = true
    }
})

-- Default curves and animations, see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })

-- Snappy spring (high stiffness, overdamped — no bounce)
hl.curve("easy",           { type = "spring", mass = 1, stiffness = 400, dampening = 45 })

-- Speed is in deciseconds (1 = 100ms); ~0.1–0.2 ≈ 10–20ms, barely perceptible
hl.animation({ leaf = "global",        enabled = true,  speed = 0.15, bezier = "linear" })
hl.animation({ leaf = "border",        enabled = true,  speed = 0.12, bezier = "linear" })
hl.animation({ leaf = "windows",       enabled = true,  speed = 0.15, spring = "easy" })
hl.animation({ leaf = "windowsIn",     enabled = true,  speed = 0.12, spring = "easy",         style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true,  speed = 0.1,  bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true,  speed = 0.1,  bezier = "linear" })
hl.animation({ leaf = "fadeOut",       enabled = true,  speed = 0.1,  bezier = "linear" })
hl.animation({ leaf = "fade",          enabled = true,  speed = 0.12, bezier = "linear" })
hl.animation({ leaf = "layers",        enabled = true,  speed = 0.12, bezier = "linear" })
hl.animation({ leaf = "layersIn",      enabled = true,  speed = 0.12, bezier = "linear",       style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true,  speed = 0.1,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true,  speed = 0.1,  bezier = "linear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true,  speed = 0.1,  bezier = "linear" })
hl.animation({ leaf = "workspaces",    enabled = true,  speed = 0.12, bezier = "linear",       style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true,  speed = 0.1,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true,  speed = 0.12, bezier = "linear",       style = "fade" })
hl.animation({ leaf = "zoomFactor",    enabled = true,  speed = 0.15, bezier = "linear" })

