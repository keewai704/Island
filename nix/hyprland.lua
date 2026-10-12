return function(options)
    local main_mod = options.modifier or "SUPER"
    local profile_keys = {}
    local state = os.getenv("XDG_STATE_HOME") or (os.getenv("HOME") .. "/.local/state")
    local file = io.open(state .. "/quickshell/keys.tsv", "r")
    if file then
        for line in file:lines() do
            local description, combination = line:match("^([^#\t][^\t]*)\t(.*)$")
            if description then
                profile_keys[description] = combination
            end
        end
        file:close()
    end

    local function bind(keys, dispatcher, description, flags)
        flags = flags or {}
        flags.description = description
        local chosen = profile_keys[description]
        if chosen == nil then
            chosen = keys
        end
        if chosen ~= "" then
            hl.bind(chosen, dispatcher, flags)
        end
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
        return bind
    end

    bind(main_mod .. " + Space", shell("launcher"), "Shell · Open the launcher")
    bind(main_mod .. " + SHIFT + Space", shell("appearance"), "Shell · Open appearance")
    bind(main_mod .. " + SHIFT + W", shell("effects"), "Island · Open the wallpaper effects")
    bind(main_mod .. " + I", shell("controls"), "Shell · Open the control centre")
    bind(main_mod .. " + Tab", shell("overview"), "Shell · Open the workspace overview")
    bind(main_mod .. " + V", shell("clipboard"), "Shell · Open the clipboard history")
    bind(main_mod .. " + X", shell("session"), "Session · Session menu")
    bind(main_mod .. " + slash", shell("keys"), "Shell · Show every key")
    bind(main_mod .. " + comma", shell("settings"), "Shell · Open settings")
    bind(main_mod .. " + period", shell("emoji"), "Shell · Pick an emoji")
    bind(main_mod .. " + SHIFT + T", shell("palette"), "Shell · Open the palette")
    bind(main_mod .. " + U", shell("stats"), "Shell · Open system statistics")
    bind(main_mod .. " + S", shell("notes"), "Shell · Open the notes")
    bind(main_mod .. " + B", shell("board"), "Shell · Open the task board")
    bind(main_mod .. " + SHIFT + C", shell("picker"), "Shell · Pick a colour off the screen")
    bind(main_mod .. " + CTRL + B", shell("zen"), "Shell · Hide or show the bar")
    bind(main_mod .. " + CTRL + W", shell("widgets"), "Shell · Hide or show the desktop widgets")
    bind("Print", shell("capture"), "Shell · Open the capture surface")
    bind("SHIFT + Print", shell("captureScreen"), "Shell · Capture the whole screen")
    bind("CTRL + Print", shell("captureWindow"), "Shell · Capture a window")
    bind(main_mod .. " + SHIFT + R", shell("record"), "Shell · Start or stop recording the screen")
    if options.lockKey then
        bind(options.lockKey, shell("lock"), "Session · Lock the screen")
    end
    bind("XF86MonBrightnessUp", shell("brightnessUp"), "Media · Brightness up", { locked = true, repeating = true })
    bind(
        "XF86MonBrightnessDown",
        shell("brightnessDown"),
        "Media · Brightness down",
        { locked = true, repeating = true }
    )
    return bind
end
