-- vim: filetype=lua fdm=marker foldenable sw=4 ts=4 sts=4

local super = { "ctrl", "alt", "cmd" }

hs.alert.defaultStyle.fillColor = { red = 0, green = 0, blue = 0, alpha = 0.6 }
hs.alert.defaultStyle.textSize = 24

-- {{{ Open Preference
hs.hotkey.bind(super, 'P', function()
    hs.openPreferences()
end)
-- }}}

-- {{{ Reload config
hs.hotkey.bind(super, 'R', function()
    hs.reload()
    hs.console.clearConsole()
    hs.alert("Reloading Hammerspoon config")
    hs.timer.doAfter(0.5, hs.reload)
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

