return function(options)
    local main_mod = options.modifier or "SUPER"
    local package = options.package

    local function bind(keys, dispatcher, description, flags)
        flags = flags or {}
        flags.description = description
        hl.bind(keys, dispatcher, flags)
    end

    local function shell(name)
        return hl.dsp.global("quickshell:" .. name)
    end

    hl.layer_rule({
        name = "island-desktop-blur",
        match = { namespace = "^(impasto-desktop)$" },
        blur = true,
        ignore_alpha = 0.12,
    })
    hl.window_rule({
        name = "island-settings",
        match = { class = "^(org\\.quickshell)$", title = "^(Settings)$" },
        float = true,
        center = true,
        size = { 980, 680 },
    })
    hl.window_rule({
        name = "island-satty",
        match = { class = "^(com\\.gabm\\.satty)$" },
        float = true,
        center = true,
        size = { 1200, 800 },
    })

    if options.look then
        hl.config({
            general = {
                gaps_in = 7,
                gaps_out = 18,
                border_size = 0,
                resize_on_border = true,
                layout = "dwindle",
            },
            decoration = {
                rounding = 22,
                rounding_power = 2,
                shadow = { enabled = false },
                blur = {
                    enabled = true,
                    size = 6,
                    passes = 2,
                    ignore_opacity = true,
                    new_optimizations = true,
                    xray = true,
                },
            },
            animations = { enabled = true },
        })
    end

    if options.binds == false then
        return
    end

    bind(main_mod .. " + Space", shell("launcher"), "Island · Open the launcher")
    bind(main_mod .. " + SHIFT + Space", shell("appearance"), "Island · Open the wallpapers")
    bind(main_mod .. " + I", shell("controls"), "Island · Open the control centre")
    bind(main_mod .. " + D", shell("overview"), "Island · Open the workspace overview")
    bind(main_mod .. " + V", shell("clipboard"), "Island · Open the clipboard history")
    bind(main_mod .. " + ALT + C", shell("session"), "Island · Session menu")
    bind(main_mod .. " + F1", shell("keys"), "Island · Show every key")
    bind(main_mod .. " + comma", shell("settings"), "Island · Open settings")
    bind(main_mod .. " + period", shell("emoji"), "Island · Pick an emoji")
    bind(main_mod .. " + SHIFT + T", shell("palette"), "Island · Open the palette")
    bind(main_mod .. " + U", shell("stats"), "Island · Open system statistics")
    bind(main_mod .. " + S", shell("notes"), "Island · Open the notes")
    bind(main_mod .. " + B", shell("board"), "Island · Open the task board")
    bind(main_mod .. " + SHIFT + C", shell("picker"), "Island · Pick a colour off the screen")
    bind(main_mod .. " + CTRL + B", shell("zen"), "Island · Hide or show the bar")
    bind(main_mod .. " + CTRL + W", shell("widgets"), "Island · Hide or show the desktop widgets")
    bind("Print", shell("capture"), "Island · Open the capture surface")
    bind("SHIFT + Print", shell("captureScreen"), "Island · Capture the whole screen")
    bind("CTRL + Print", shell("captureWindow"), "Island · Capture a window")
    bind(main_mod .. " + SHIFT + R", shell("record"), "Island · Start or stop recording")
    bind(
        main_mod .. " + SHIFT + W",
        hl.dsp.exec_cmd(package .. "/bin/island-wallpaper-effect"),
        "Island · Apply a wallpaper effect"
    )
    if options.lockKey then
        bind(options.lockKey, shell("lock"), "Island · Lock the screen")
    end
    bind("XF86MonBrightnessUp", shell("brightnessUp"), "Island · Brightness up", { locked = true, repeating = true })
    bind(
        "XF86MonBrightnessDown",
        shell("brightnessDown"),
        "Island · Brightness down",
        { locked = true, repeating = true }
    )
end
