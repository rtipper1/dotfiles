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
    floatingTerminal = "ghostty --class=com.ghostty.floating --background-opacity=0.65",

    -- Window classes (for matching in window rules; may differ from binary names)
    classes = {
        browser          = "brave",
        floatingTerminal = "com.ghostty.floating",
    },
}
