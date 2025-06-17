local mouseModeActive = false
local ctrlTapTimer = nil
local ctrlLastTap = 0
local moveTimer = nil
local moveKeys = {}
local baseSpeed = 10
local speed = baseSpeed

-- Movement vector mapping
local directions = {
    h = { -1, 0 },
    j = { 0, 1 },
    k = { 0, -1 },
    l = { 1, 0 },
}

-- Start mouse move loop
local function startMouseMove()
    if moveTimer then
        return
    end
    moveTimer = hs.timer.doEvery(0.01, function()
        local dx, dy = 0, 0
        for key, active in pairs(moveKeys) do
            if active and directions[key] then
                dx = dx + directions[key][1]
                dy = dy + directions[key][2]
            end
        end
        if dx ~= 0 or dy ~= 0 then
            local pos = hs.mouse.getAbsolutePosition()
            hs.mouse.setAbsolutePosition({ x = pos.x + dx * speed, y = pos.y + dy * speed })
        end
    end)
end

local function stopMouseMove()
    if moveTimer then
        moveTimer:stop()
        moveTimer = nil
    end
end

-- Enable/disable mouse movement mode
local function setMouseMode(active)
    if mouseModeActive == active then
        return
    end
    mouseModeActive = active
    hs.alert.closeAll()
    if active then
        hs.alert("Mouse Mode ON")
        startMouseMove()
    else
        hs.alert("Mouse Mode OFF")
        stopMouseMove()
        moveKeys = {}
        speed = baseSpeed
    end
end

-- Double-tap and hold Control detection
local ctrlWatcher = hs.eventtap.new({ hs.eventtap.event.types.flagsChanged }, function(e)
    local flags = e:getFlags()
    if flags.ctrl and not mouseModeActive then
        local now = hs.timer.secondsSinceEpoch()
        if now - ctrlLastTap < 0.3 then
            ctrlTapTimer = hs.timer.doAfter(0.3, function()
                if hs.eventtap.checkKeyboardModifiers().ctrl then
                    setMouseMode(true)
                end
            end)
        end
        ctrlLastTap = now
    elseif not flags.ctrl and mouseModeActive then
        setMouseMode(false)
    end
    return false
end)
ctrlWatcher:start()

-- Movement key press/release handler
local keyWatcher = hs.eventtap.new({ hs.eventtap.event.types.keyDown, hs.eventtap.event.types.keyUp }, function(e)
    if not mouseModeActive then
        return false
    end

    local key = hs.keycodes.map[e:getKeyCode()]
    if not key then
        return false
    end

    local isDown = (e:getType() == hs.eventtap.event.types.keyDown)

    if directions[key] ~= nil then
        moveKeys[key] = isDown
        return true
    elseif key == "a" then
        speed = isDown and 30 or baseSpeed
        return true
    elseif key == "s" then
        speed = isDown and 5 or baseSpeed
        return true
    end

    return false
end)
keyWatcher:start()
