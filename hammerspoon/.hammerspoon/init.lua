-- vim: filetype=lua fdm=marker foldenable sw=4 ts=4 sts=4

local super = { "ctrl", "alt", "cmd" }

-- {{{ Open Preference
hs.hotkey.bind(super, 'P', function()
    hs.openPreferences()
end)
-- }}}

-- {{{ Reload config
hs.hotkey.bind(super, 'R', function()
    hs.reload()
    hs.console.clearConsole()
end)
-- }}}

local config = require 'config'

hs.loadSpoon("SpoonInstall")
hs.loadSpoon("EmmyLua")

-- {{{ Show Clock

hs.loadSpoon("AClock")
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "T", function()
    spoon.AClock:toggleShow()
end)

-- }}}

-- {{{ WiFi - Notify and mute audio

local wifi = require 'wifi';
wifi:init(config.homeNetworks)

--- }}}

