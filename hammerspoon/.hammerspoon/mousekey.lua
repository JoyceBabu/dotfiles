--[[
MouseKey – Keyboard‑driven mouse control for Hammerspoon
════════════════════════════════════════════════════════
Tap **Control** once (by itself) to *prime* Mouse Mode, then press‑and‑hold
Control to activate it. While Control is held:
  h j k l   → move cursor   (accelerates: slow → normal → fast)
  m , .     → left / middle / right click
  u / n     → scroll up / down
  b         → toggle wrap‑around at screen edges
Visual cues
  • Alert on enter / exit
  • Tiny green “M” badge sits in a corner and hops away when the cursor
    approaches it.
Mouse Mode exits when Control is released *or* the physical mouse moves.
All state is cleaned up on Hammerspoon reload/quit.
--------------------------------------------------------------------]]

------------------------------ CONFIG ------------------------------
local speedMin = 4 -- px per tick the instant a key is pressed
local speedMax = 36 -- px per tick after a long hold
local speedCurveK = 5 -- curve steepness (higher = snappier ramp-up)
local speedCurveMid = 0.5 -- seconds at which speed is halfway (σ = 0.5)

local scrollSpeedMin = 10 -- px per tick at key press
local scrollSpeedMax = 200 -- px per tick after a long hold
local scrollCurveK = 0.3 -- steepness of the sigmoid
local scrollCurveMid = 0.8 -- sec at which speed is halfway

local ctrlPrimeDelay = 0.6 -- delay for second control press
local tickRate = 0.02 -- sec between cursor updates (≈50 Hz)
local logLevel = "info" -- 'debug' | 'info' | 'warning'

local iconOffset = { x = 10, y = 5 }
local iconDistance = 40 -- px before badge hops
local iconSize = { w = 45, h = 22 }
local iconText = " M "
local iconFont = "Helvetica-Bold"
local iconFontSize = 14
--------------------------------------------------------------------

local log = hs.logger.new("MouseKey", logLevel)

-- use wall-clock time instead of CPU time
local now = hs.timer.secondsSinceEpoch

------------------------------- STATE ------------------------------
local mouseMode = false -- inside Mouse Mode right now?
local primed = nil -- Control was tapped once
local primedTimer = nil -- clears the primed flag
local moveTimer = nil -- drives continuous cursor motion
local wrapEdges = false
local lastProgMove = 0 -- last timestamp we moved the cursor
local badge = nil -- hs.drawing for the "M" badge
local badgeCorner = 1 -- 1 BL → 2 BR → 3 TR → 4 TL
local activeKeys = {} -- keyCode → true while held
local pressStart = nil -- timestamp when first movement key pressed
local lastClickAt = 0 -- timestamp of previous click
local lastClickPos = nil -- position of previous click
local scrollTimer = nil -- drives continuous scroll
local scrollPressStart = nil -- when the scroll key was first held
local activeScrollDir = 0 --  1 = up, –1 = down
--------------------------- KEY HELPERS ----------------------------
local function keyCode(key)
    local code = hs.keycodes.map[key] or (#key == 1 and hs.keycodes.keyCodeForChar(key))
    if not code then
        log.wf("Key '%s' not in keymap – binding skipped", key)
    end
    return code
end

--------------------------- KEY MAPS -------------------------------
local moveKeys, clickKeys, scrollKeys = {}, {}, {}
for k, vec in pairs({ h = { -1, 0 }, j = { 0, 1 }, k = { 0, -1 }, l = { 1, 0 } }) do
    local c = keyCode(k)
    if c then
        moveKeys[c] = vec
    end
end

clickKeys[keyCode("m")] = function()
    hs.eventtap.leftClick(hs.mouse.absolutePosition())
end

clickKeys[keyCode(",")] = function()
    hs.eventtap.otherClick(hs.mouse.absolutePosition(), 2)
end

clickKeys[keyCode(".")] = function()
    hs.eventtap.rightClick(hs.mouse.absolutePosition())
end

local wrapToggle = keyCode("b")
local scrollUpKey = keyCode("y")
local scrollDownKey = keyCode("e")

------------------------------ BADGE -------------------------------
local function updateBadgePosition(pos, newPos)
    if not badge then
        return
    end

    local bf = badge:frame()
    if
        newPos ~= nil
        or math.abs(pos.x - (bf.x + bf.w / 2)) < iconDistance and math.abs(pos.y - (bf.y + bf.h / 2)) < iconDistance
    then
        badgeCorner = newPos or (badgeCorner % 4) + 1
        local ow, oh = bf.w, bf.h
        local f = hs.screen.mainScreen():fullFrame()
        local corners = {
            { x = f.x, y = f.y + f.h - oh },
            { x = f.x + f.w - ow, y = f.y + f.h - oh },
            { x = f.x + f.w - ow, y = f.y },
            { x = f.x, y = f.y },
        }
        badge:topLeft(corners[badgeCorner])
    end
end

local function showBadge()
    if badge then
        badge:delete()
        badge = nil
    end

    badge = hs.canvas.new({
        x = 0,
        y = 0,
        w = iconSize.w + iconOffset.x * 2,
        h = iconSize.h + iconOffset.y * 2,
    })
    badge:appendElements({
        type = "rectangle",
        fillColor = { red = 0.2, green = 0.2, blue = 0.8, alpha = 0.85 },
        strokeColor = { white = 0.5, alpha = 0.5 },
        strokeWidth = 1,
        radius = 5,
        frame = { x = iconOffset.x, y = iconOffset.y, w = iconSize.w, h = iconSize.h },
    })
    badge:appendElements({
        type = "text",
        text = iconText,
        textColor = { white = 1, alpha = 1.0 },
        textFont = iconFont,
        textSize = iconFontSize,
        frame = { x = iconOffset.x, y = iconOffset.y, w = iconSize.w, h = iconSize.h },
        textAlignment = "center",
    })

    updateBadgePosition(hs.mouse.absolutePosition(), 1)
    badge:show()
end

local function hideBadge()
    if badge then
        badge:delete()
        badge = nil
    end
end

--------------------------- UTILITIES ------------------------------
local function sigmoid(start, curveK, curveMid, min, max)
    if not start then
        return min
    end

    local held = now() - start
    local logistic = 1 / (1 + math.exp(-curveK * (held - curveMid)))
    local sigma0 = 1 / (1 + math.exp(curveK * curveMid))
    local sigma = (logistic - sigma0) / (1 - sigma0)

    if sigma < 0 then
        sigma = 0
    end

    return min + math.floor((max - min) * sigma)
end

local function currentSpeed()
    return sigmoid(pressStart, speedCurveK, speedCurveMid, speedMin, speedMax)
end

local function clampOrWrap(pt)
    if wrapEdges then
        -- Wrap across virtual desktop bounds (all screens)
        local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
        for _, s in ipairs(hs.screen.allScreens()) do
            local f = s:fullFrame()
            minX, minY = math.min(minX, f.x), math.min(minY, f.y)
            maxX, maxY = math.max(maxX, f.x + f.w), math.max(maxY, f.y + f.h)
        end
        if pt.x < minX then
            pt.x = maxX - 1
        elseif pt.x >= maxX then
            pt.x = minX
        end
        if pt.y < minY then
            pt.y = maxY - 1
        elseif pt.y >= maxY then
            pt.y = minY
        end
    else
        -- Clamp inside current screen
        local f = hs.mouse.getCurrentScreen():fullFrame()
        pt.x = math.min(math.max(pt.x, f.x), f.x + f.w - 1)
        pt.y = math.min(math.max(pt.y, f.y), f.y + f.h - 1)
    end
    return pt
end

local function moveCursor(dx, dy)
    local pos = hs.mouse.absolutePosition()
    local speed = currentSpeed()
    local new = { x = pos.x + dx * speed, y = pos.y + dy * speed }
    hs.mouse.absolutePosition(clampOrWrap(new))
    lastProgMove = now()

    updateBadgePosition(new)
end

local function currentScrollSpeed()
    return sigmoid(scrollPressStart, scrollCurveK, scrollCurveMid, scrollSpeedMin, scrollSpeedMax)
end

local function startScroll(dir)
    -- start or change direction
    activeScrollDir = dir
    if not scrollTimer then
        scrollPressStart = now()
        scrollTimer = hs.timer.doEvery(tickRate, function()
            if activeScrollDir ~= 0 then
                local delta = currentScrollSpeed() * activeScrollDir
                log.d("Delta", delta)
                hs.eventtap.scrollWheel({ 0, delta }, {}, "pixel")
            end
        end)
    end
end

local function endScroll()
    activeScrollDir = 0
    scrollPressStart = nil
    if scrollTimer then
        scrollTimer:stop()
        scrollTimer = nil
    end
end
--------------------------- KEY WATCHER ----------------------------
local keyWatcher
local keyUp = hs.eventtap.event.types.keyUp
local keyDown = hs.eventtap.event.types.keyDown

local function startKeyWatcher()
    keyWatcher = hs.eventtap
        .new({ keyDown, keyUp }, function(e)
            if not mouseMode then
                return false
            end
            local code, etype = e:getKeyCode(), e:getType()

            -- movement keys
            if moveKeys[code] then
                if etype == keyDown and not activeKeys[code] then
                    local firstKey = next(activeKeys) == nil
                    activeKeys[code] = true
                    if firstKey then
                        pressStart = now()
                    end

                    if not moveTimer then
                        moveTimer = hs.timer.doEvery(tickRate, function()
                            local dx, dy = 0, 0
                            for k, _ in pairs(activeKeys) do
                                local d = moveKeys[k]
                                dx, dy = dx + d[1], dy + d[2]
                            end
                            if dx ~= 0 or dy ~= 0 then
                                moveCursor(dx, dy)
                            end
                        end)
                    end
                elseif etype == keyUp then
                    activeKeys[code] = nil
                    if next(activeKeys) == nil then
                        pressStart = nil
                        if moveTimer then
                            moveTimer:stop()
                            moveTimer = nil
                        end
                    end
                end
                return true
            end

            -- clicks
            if clickKeys[code] and etype == keyDown then
                clickKeys[code]()
                return true
            end

            -- scroll
            if code == scrollUpKey or code == scrollDownKey then
                local dir = (code == scrollUpKey) and 1 or -1
                if etype == keyDown then
                    startScroll(dir)
                else
                    endScroll()
                end
                return true
            end

            -- wrap toggle
            if wrapToggle and code == wrapToggle and etype == keyDown then
                wrapEdges = not wrapEdges
                hs.alert.show("Wrap " .. (wrapEdges and "ON" or "OFF"), 0.4)
                return true
            end
            return false
        end)
        :start()
end

---------------------- ENTER / EXIT MODE ---------------------------
local function setKarabinerVariable(val)
    hs.task.new("/opt/homebrew/bin/karabiner_cli", nil, { "--set-variables", '{"mouse_mode":' .. val .. "}" }):start()
end

local function enterMouseMode()
    if mouseMode then
        return
    end
    mouseMode = true
    log.i("Enter Mouse Mode")
    hs.alert.show("🖱️ Mouse Mode", 0.6)
    showBadge()
    startKeyWatcher()
    setKarabinerVariable(1)
end

local function exitMouseMode(reason)
    if not mouseMode then
        return
    end

    log.i("Exit Mouse Mode – " .. (reason or "?"))
    hs.alert.show("Mouse Mode Off", 0.4)
    mouseMode = false
    activeKeys, pressStart = {}, nil

    if keyWatcher then
        keyWatcher:stop()
        keyWatcher = nil
    end

    if moveTimer then
        moveTimer:stop()
        moveTimer = nil
    end

    endScroll()
    hideBadge()
    setKarabinerVariable(0)
end

---------------------- CONTROL‑KEY PRIMING -------------------------
local flagsWatcher = hs.eventtap
    .new({ hs.eventtap.event.types.flagsChanged }, function(e)
        local flags = e:getFlags()
        local ctrl = flags.ctrl
        local ctrlOnly = flags:containExactly({ "ctrl" })

        if ctrlOnly and primed == nil then
            -- Control is down. Wait for release and second tap.
            primed = false
            if primedTimer then
                primedTimer:stop()
            end
            primedTimer = hs.timer.doAfter(ctrlPrimeDelay, function()
                primed = nil
            end)

            return false
        end

        if primed == false and next(flags) == nil then
            -- Wait for next control press
            primed = true
        end

        if ctrlOnly and primed and not mouseMode then
            -- Control is primed. Enter mouse mode.
            primed = nil
            if primedTimer then
                primedTimer:stop()
                primedTimer = nil
            end
            enterMouseMode()
        end

        if not ctrl and mouseMode then
            primed = nil
            exitMouseMode("Control released")
        end

        return false
    end)
    :start()

--------------------- PHYSICAL MOUSE MOVEMENT ----------------------
local physWatcher = hs.eventtap
    .new({ hs.eventtap.event.types.mouseMoved }, function()
        if mouseMode and (now() - lastProgMove) > 0.25 then
            exitMouseMode("Physical move")
        end
        return false
    end)
    :start()

----------------------------- CLEANUP ------------------------------
local function cleanup()
    exitMouseMode("Cleanup")
    if flagsWatcher then
        flagsWatcher:stop()
        flagsWatcher = nil
    end
    if physWatcher then
        physWatcher:stop()
        physWatcher = nil
    end
    if primedTimer then
        primedTimer:stop()
        primedTimer = nil
    end
    log.i("MouseKey cleaned up")
end
hs.shutdownCallback = cleanup

log.i("MouseKey loaded – tap Control, then hold to steer the pointer")

return true
