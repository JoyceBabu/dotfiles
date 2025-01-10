local M = {}
local lastSSID = hs.wifi.currentNetwork()
local newSSID = nil

M.homeMuted = nil

-- Required to add HammerSpoon to location services
print(hs.location.get())

function M:isHomeNetwork(value)
    for _idx, val in ipairs(self.homeNetworks) do
        if val == value then
            print("Home network detected")
            return true
        end
    end

    return false
end

function M:mute()
    local device = hs.audiodevice.defaultOutputDevice()
    if device then
        device:setOutputMuted(true)
    end
end

function M:unmute()
    local device = hs.audiodevice.defaultOutputDevice()
    if device and self.homeMuted ~= nil then
        print("Restoring audio: " .. (self.homeMuted and "true" or "false"))
        device:setOutputMuted(self.homeMuted)
    end
end

function M:saveOutputAudioState()
    local device = hs.audiodevice.defaultOutputDevice()
    if device then
        self.homeMuted = device:outputMuted()
        -- self.homeVolume = device:volume()
        print("Saving last audio state: " .. (self.homeMuted and "true" or "false"))
    end
end

function M:handleWifiChange()
    newSSID = hs.wifi.currentNetwork()

    if newSSID == lastSSID then
        return
    end

    if newSSID then
        if self:isHomeNetwork(newSSID) then
            -- Entering home network. Restore audio state.
            self:unmute()
        elseif newSSID ~= lastSSID then
            -- Leaving home network. Mute audio.
            self:mute()
        end
    elseif self:isHomeNetwork(lastSSID) then
        -- Save volume level on leaving home
        self:saveOutputAudioState()
    end

    if newSSID == nil then
        title = "Wifi disconnected"
        informativeText = "Left " .. (lastSSID or "Unknown Network")
    elseif lastSSID == nil then
        title = "Wifi connected"
        informativeText = "Joined " .. newSSID
    else
        title = "Network Change"
        informativeText = "Left " .. lastSSID .. ". Joined " .. newSSID .. "."
    end

    print(title .. ": " .. informativeText)

    hs.notify.new({
        title = title,
        informativeText = informativeText
    }):send()

    lastSSID = newSSID
end

function M:init(homeNetworks)
    self.homeNetworks = homeNetworks

    local wifiNotifier = hs.wifi.watcher.new(function()
        self:handleWifiChange()
    end)

    wifiNotifier:start()
end

return M
