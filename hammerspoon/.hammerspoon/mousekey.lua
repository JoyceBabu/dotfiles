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
local moveSpeeds = { 4, 12, 32 } -- px/step: slow, normal, fast
local speedThreshold = { 0.4, 1.0 } -- seconds held for speed steps
local tickRate = 0.02 -- seconds between movement ticks
local iconDistance = 40 -- px before the badge hops corner
local logLevel = "info" -- 'debug' | 'info' | 'warning'
--------------------------------------------------------------------

local log = hs.logger.new("MouseKey", logLevel)

------------------------------- STATE ------------------------------
local mouseMode = false -- inside Mouse Mode right now?
local primed = false -- Control was tapped once
local primedTimer = nil -- clears the primed flag
local moveTimer = nil -- drives continuous cursor motion
local wrapEdges = false
local activeKeys = {} -- keyCode → true while pressed
local holdStart = {} -- keyCode → press timestamp
local lastProgMove = 0 -- last timestamp we moved the cursor
local badge = nil -- hs.drawing for the "M" badge
local badgeCorner = 1 -- 1 BL → 2 BR → 3 TR → 4 TL

local function kcOf(key)
    -- Resolve a key name or literal char to a key‑code for *this* layout.
    local code = hs.keycodes.map[key]
    if not code and #key == 1 then
        code = hs.keycodes.keyCodeForChar(key)
    end
--------------------------- KEY HELPERS ----------------------------
    if not code then
        log.wf("Key '%s' not in keymap – binding skipped", key)
    end
    return code
end

--------------------------- KEY MAPS -------------------------------
local moveKeys, clickKeys, scrollKeys = {}, {}, {}
for k, vec in pairs({ h = { -1, 0 }, j = { 0, 1 }, k = { 0, -1 }, l = { 1, 0 } }) do
    local kc = kcOf(k)
    if kc then
        moveKeys[kc] = vec
    end
end
local kcM = kcOf("m")
if kcM then
    clickKeys[kcM] = function()
        hs.eventtap.leftClick(hs.mouse.absolutePosition())
    end
end
local kcC = kcOf(",")
if kcC then
    clickKeys[kcC] = function()
        hs.eventtap.otherClick(hs.mouse.absolutePosition(), 2)
    end
end
local kcP = kcOf(".")
if kcP then
    clickKeys[kcP] = function()
        hs.eventtap.rightClick(hs.mouse.absolutePosition())
    end
end
local kcU = kcOf("u")
if kcU then
    scrollKeys[kcU] = function()
        hs.eventtap.scrollWheel({ 0, 60 }, {}, "pixel")
    end
end
local kcN = kcOf("n")
if kcN then
    scrollKeys[kcN] = function()
        hs.eventtap.scrollWheel({ 0, -60 }, {}, "pixel")
    end
end
local wrapToggleKc = kcOf("b")

--------------------------- UTILITIES ------------------------------
local function currentSpeed()
    local now, oldest = os.clock(), os.clock()
    for _, t in pairs(holdStart) do
        if t < oldest then
            oldest = t
        end
    end
    local held = now - oldest
    return (held < speedThreshold[1]) and moveSpeeds[1] or (held < speedThreshold[2]) and moveSpeeds[2] or moveSpeeds[3]
end

local function clampOrWrap(pt)
    if wrapEdges then
        -- Wrap across virtual desktop bounds (all screens)
        local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
        for _, s in ipairs(hs.screen.allScreens()) do
            local f = s:frame()
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
        local f = hs.mouse.getCurrentScreen():frame()
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
    -- badge hop logic
    if badge then
        local bf = badge:frame()
        if
            math.abs(new.x - (bf.x + bf.w / 2)) < iconDistance
            and math.abs(new.y - (bf.y + bf.h / 2)) < iconDistance
        then
            badgeCorner = (badgeCorner % 4) + 1
            local f = hs.screen.mainScreen():frame()
            local cr = {
                { x = f.x + 4, y = f.y + f.h - 24 },
                { x = f.x + f.w - 20, y = f.y + f.h - 24 },
                { x = f.x + f.w - 20, y = f.y + 4 },
                { x = f.x + 4, y = f.y + 4 },
            }
            badge:setTopLeft(cr[badgeCorner])
        end
    end
end

------------------------------ BADGE -------------------------------
local function showBadge()
    if badge then
        badge:delete()
    end
    local sf = hs.screen.mainScreen():frame()
    badgeCorner = 1
    badge = hs.drawing.text(hs.geometry.rect(sf.x + 4, sf.y + sf.h - 24, 16, 20), "M")
    badge
        :setLevel(hs.drawing.windowLevels.status)
        :setBehavior(hs.drawing.windowBehaviors.canJoinAllSpaces)
        :setTextColor({ hex = "#00ff00" })
        :setAlpha(0.8)
        :show()
end

--------------------------- KEY WATCHER ----------------------------
local keyWatcher, moveTimer
local function startKeyWatcher()
    keyWatcher = hs.eventtap
        .new({ hs.eventtap.event.types.keyDown, hs.eventtap.event.types.keyUp }, function(e)
            if not mouseMode then
                return false
            end
            local code, etype = e:getKeyCode(), e:getType()
            if moveKeys[code] then -- movement keys
                if etype == hs.eventtap.event.types.keyDown and not activeKeys[code] then
                    activeKeys[code] = true
                    holdStart[code] = os.clock()
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
                elseif etype == hs.eventtap.event.types.keyUp then
                    activeKeys[code], holdStart[code] = nil, nil
                    if not next(activeKeys) and moveTimer then
                        moveTimer:stop()
                        moveTimer = nil
                    end
                end
                return true -- swallow
            elseif clickKeys[code] and etype == hs.eventtap.event.types.keyDown then
                clickKeys[code]()
                return true
            elseif scrollKeys[code] and etype == hs.eventtap.event.types.keyDown then
                scrollKeys[code]()
                return true
            elseif wrapToggleKc and code == wrapToggleKc and etype == hs.eventtap.event.types.keyDown then
                wrapEdges = not wrapEdges
                hs.alert.show("Wrap " .. (wrapEdges and "ON" or "OFF"), 0.4)
                return true
            end
            return false
        end)
        :start()
end

---------------------- ENTER / EXIT MODE ---------------------------
local function enterMouseMode()
    if mouseMode then
        return
    end
    mouseMode = true
    log.i("Enter Mouse Mode")
    hs.alert.show("🖱️ Mouse Mode", 0.6)
    showBadge()
    startKeyWatcher()
end

local function exitMouseMode(reason)
    if not mouseMode then
        return
    end
    log.i("Exit Mouse Mode – " .. (reason or "?"))
    hs.alert.show("Mouse Mode Off", 0.4)
    mouseMode = false
    if keyWatcher then
        keyWatcher:stop()
        keyWatcher = nil
    end
    if moveTimer then
        moveTimer:stop()
        moveTimer = nil
    end
    activeKeys, holdStart = {}, {}
    if badge then
        badge:delete()
        badge = nil
    end
end

---------------------- CONTROL‑KEY PRIMING -------------------------
local flagsWatcher = hs.eventtap
    .new({ hs.eventtap.event.types.flagsChanged }, function(e)
        local flags = e:getFlags()
        local ctrlDown = flags.ctrl
        if ctrlDown and primed and not mouseMode then
            primed = false
            if primedTimer then
                primedTimer:stop()
                primedTimer = nil
            end
            enterMouseMode()
        elseif not ctrlDown and mouseMode then
            exitMouseMode("Control released")
        end
        if not ctrlDown and next(flags) == nil then -- solitary control tap
            primed = true
            if primedTimer then
                primedTimer:stop()
            end
            primedTimer = hs.timer.doAfter(0.8, function()
                primed = false
            end)
        end
        return false
    end)
    :start()

--------------------- PHYSICAL MOUSE MOVEMENT ----------------------
local physWatcher = hs.eventtap
    .new({ hs.eventtap.event.types.mouseMoved }, function()
        if mouseMode and os.clock() - lastProgMove > 0.2 then
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
