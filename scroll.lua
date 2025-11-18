-- Smooth scrolling with Ctrl+Cmd+Opt+Arrow keys
-- Configuration
local scrollSpeed = 3  -- Lines per scroll event (higher = faster)
local scrollDelay = 0.03  -- Seconds between scroll events when held (~30fps)

-- State tracking
local scrollTimer = nil
local currentDirection = nil

local function smoothScroll(direction, lines)
    local win = hs.window.focusedWindow()
    if not win then return end

    -- Get the focused window's frame to position scroll events correctly
    local frame = win:frame()
    local centerX = frame.x + frame.w / 2
    local centerY = frame.y + frame.h / 2

    -- Save current mouse position
    local originalPos = hs.mouse.absolutePosition()

    -- Move mouse to center of focused window (so scroll targets the right window)
    hs.mouse.absolutePosition({x = centerX, y = centerY})

    -- Create scroll event
    if direction == "up" then
        hs.eventtap.event.newScrollEvent({0, lines}, {}, 'line'):post()
    elseif direction == "down" then
        hs.eventtap.event.newScrollEvent({0, -lines}, {}, 'line'):post()
    elseif direction == "left" then
        hs.eventtap.event.newScrollEvent({lines, 0}, {}, 'line'):post()
    elseif direction == "right" then
        hs.eventtap.event.newScrollEvent({-lines, 0}, {}, 'line'):post()
    end

    -- Restore mouse position
    hs.mouse.absolutePosition(originalPos)
end

local function startScrolling(direction)
    currentDirection = direction

    -- Scroll immediately
    smoothScroll(direction, scrollSpeed)

    -- Start continuous scrolling
    if scrollTimer then
        scrollTimer:stop()
    end

    scrollTimer = hs.timer.doEvery(scrollDelay, function()
        if currentDirection then
            smoothScroll(currentDirection, scrollSpeed)
        end
    end)
end

local function stopScrolling()
    currentDirection = nil
    if scrollTimer then
        scrollTimer:stop()
        scrollTimer = nil
    end
end

-- Bind the scroll keys with press/release functions
hs.hotkey.bind({"ctrl", "cmd", "alt"}, "up",
    function() startScrolling("up") end,
    function() stopScrolling() end
)

hs.hotkey.bind({"ctrl", "cmd", "alt"}, "down",
    function() startScrolling("down") end,
    function() stopScrolling() end
)

hs.hotkey.bind({"ctrl", "cmd", "alt"}, "left",
    function() startScrolling("left") end,
    function() stopScrolling() end
)

hs.hotkey.bind({"ctrl", "cmd", "alt"}, "right",
    function() startScrolling("right") end,
    function() stopScrolling() end
)

hs.alert.show("Scroll keys loaded")
