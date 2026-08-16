-------------------
---- DEFAULT APPS ----
-------------------

-- Shared app definitions for binds, autostart, and window rules.

return {
    terminal    = "ghostty",
    fileManager = "dolphin",
    menu        = "hyprlauncher", -- Not added yet
    browser     = "brave",
    wallpaper   = "hyprpaper",
    bar         = "waybar", -- Not added yet

    -- Launch command for the floating Ghostty scratch terminal
    -- Override global fullscreen=true so the float rule can size/center it
    floatingTerminal = "ghostty --class=com.ghostty.floating --fullscreen=false",

    -- Window classes (for matching in window rules; may differ from binary names)
    classes = {
        browser          = "brave-browser",
        floatingTerminal = "com.ghostty.floating",
    },
}
