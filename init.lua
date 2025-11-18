-- Hammerspoon Configuration
-- Reload this file: Cmd+Alt+Ctrl+R

--------------------------------------------------------------------------------
-- SETUP & RELOAD
--------------------------------------------------------------------------------

-- Show notification when config loads
hs.notify.new({title="Hammerspoon", informativeText="Config loaded"}):send()

-- Reload config shortcut
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "R", function()
  hs.reload()
end)

--------------------------------------------------------------------------------
-- SMOOTH SCROLLING
--------------------------------------------------------------------------------
require("scroll")

--------------------------------------------------------------------------------
-- WINDOW MANAGEMENT - Move Between Monitors
--------------------------------------------------------------------------------

-- Move window to next monitor
hs.hotkey.bind({"alt", "ctrl"}, "Up", function()
  local win = hs.window.focusedWindow()
  if win then
    local nextScreen = win:screen():next()
    win:moveToScreen(nextScreen)
    hs.notify.new({title="Window Moved", informativeText="Moved to next monitor"}):send()
  end
end)

-- Move window to previous monitor
hs.hotkey.bind({"alt", "ctrl"}, "Down", function()
  local win = hs.window.focusedWindow()
  if win then
    local prevScreen = win:screen():previous()
    win:moveToScreen(prevScreen)
    hs.notify.new({title="Window Moved", informativeText="Moved to previous monitor"}):send()
  end
end)

--------------------------------------------------------------------------------
-- APPLICATION SWITCHING
--------------------------------------------------------------------------------

-- Load machine-specific app configuration
local function loadApps()
  -- Try to load machine-local config (gitignored)
  local success, config = pcall(require, "machine-local")
  local profile = "work"  -- default

  if success and config.profile then
    profile = config.profile
    print("Loading apps profile: " .. profile)
  else
    print("No machine-local.lua found, using work profile")
  end

  -- Load the appropriate apps file
  local apps_file = "apps-" .. profile
  local apps_success, apps = pcall(require, apps_file)

  if apps_success then
    print("Loaded " .. apps_file .. ".lua")
    return apps
  else
    print("ERROR: Could not load " .. apps_file .. ".lua")
    return {}
  end
end

local apps = loadApps()

-- Create hotkeys for all apps using Cmd+Alt+Key
for key, app in pairs(apps) do
  hs.hotkey.bind({"cmd", "alt"}, key, function()
    hs.application.launchOrFocus(app)
  end)
end

--------------------------------------------------------------------------------
-- TOGGLE APP (Hide if active, show if not)
--------------------------------------------------------------------------------

-- Toggle function - useful for terminal/notes
function toggleApp(appName)
  local app = hs.application.find(appName)
  if app and app:isFrontmost() then
    app:hide()
  else
    hs.application.launchOrFocus(appName)
  end
end

-- Create toggle hotkeys for all apps using Cmd+Alt+Shift+Key
for key, app in pairs(apps) do
  hs.hotkey.bind({"cmd", "alt", "shift"}, key, function()
    toggleApp(app)
  end)
end

--------------------------------------------------------------------------------
-- ZOOM AUDIO TOGGLE
--------------------------------------------------------------------------------

-- Toggle Zoom audio (mute/unmute) with TAB (hyper/Cmd+Alt) + A
-- Works even when Zoom is not the active app
hs.hotkey.bind({"cmd", "alt", "shift"}, "a", function()
  -- Try multiple possible Zoom identifiers
  local zoom = hs.application.find("zoom.us") or
               hs.application.find("Zoom") or
               hs.application.find("us.zoom.xos")

  if zoom then
    print("Found Zoom app: " .. zoom:name() .. " (bundle: " .. (zoom:bundleID() or "unknown") .. ")")

    -- Activate Zoom, send keystroke, then return to previous app
    local currentApp = hs.application.frontmostApplication()
    zoom:activate()
    hs.timer.usleep(50000) -- Wait 50ms for activation
    hs.eventtap.keyStroke({"cmd", "shift"}, "a")
    hs.timer.usleep(50000) -- Wait 50ms for keystroke
    if currentApp then
      currentApp:activate()
    end
    hs.notify.new({title="Zoom", informativeText="Audio toggled"}):send()
  else
    -- Debug: list all running apps
    print("Zoom not found. Running apps:")
    for _, app in ipairs(hs.application.runningApplications()) do
      if app:name():lower():find("zoom") then
        print("  Found: " .. app:name() .. " (bundle: " .. (app:bundleID() or "unknown") .. ")")
      end
    end
    hs.notify.new({title="Zoom", informativeText="Zoom is not running"}):send()
  end
end)

--------------------------------------------------------------------------------
-- UTILITY FUNCTIONS
--------------------------------------------------------------------------------

-- Get bundle ID of frontmost app (useful for configuration)
-- Run this in Hammerspoon console: hs.application.frontmostApplication():bundleID()

-- Log when config is loaded
print("Hammerspoon config loaded successfully!")
