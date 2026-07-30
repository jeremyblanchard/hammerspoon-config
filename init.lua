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

-- Holding the keyboard's Tab key activates its dedicated App layer. Each app
-- position sends Cmd+Ctrl+Alt plus a function key from F13 through F24.
-- This private synthetic namespace avoids macOS and application shortcuts.
local appSignalMods = {"cmd", "ctrl", "alt"}
local zoomSignalMods = {"cmd", "ctrl", "alt", "shift"}
local appSignals = {
  ["A"] = "F13",
  ["S"] = "F14",
  ["D"] = "F15",
  ["F"] = "F16",
  ["G"] = "F17",
  ["Z"] = "F18",
  ["X"] = "F19",
  ["C"] = "F20",
  ["V"] = "F21",
  ["B"] = "F22",
  ["O"] = "F23",
  ["L"] = "F24"
}

local function warnIfSystemAssigned(mods, key, description)
  if hs.hotkey.systemAssigned(mods, key) then
    print("WARNING: macOS has assigned " .. description)
  end
end

local function bindAppSignal(key, app)
  local signal = appSignals[key]
  if not signal then
    print("WARNING: No keyboard App-layer signal configured for " .. key .. " (" .. app .. ")")
    return
  end

  warnIfSystemAssigned(appSignalMods, signal, "app signal " .. signal)
  hs.hotkey.bind(appSignalMods, signal, function()
    hs.application.launchOrFocus(app)
  end)
end

for key, app in pairs(apps) do
  bindAppSignal(key, app)
end

--------------------------------------------------------------------------------
-- ZOOM AUDIO TOGGLE
--------------------------------------------------------------------------------

-- App-layer E sends Cmd+Ctrl+Alt+Shift+F13. Map it to Cmd+Shift+A.
-- With Zoom's native global shortcut enabled for mute/unmute, this toggles audio
-- without activating Zoom or changing focus.
local function sendZoomAudioShortcut()
  hs.eventtap.keyStroke({"cmd", "shift"}, "A")
  print("Mapped App-layer E to Cmd+Shift+A")
  hs.notify.new({title="Zoom", informativeText="Audio shortcut sent"}):send()
end

warnIfSystemAssigned(zoomSignalMods, "F13", "Zoom audio signal Shift+F13")
hs.hotkey.bind(zoomSignalMods, "F13", sendZoomAudioShortcut)

--------------------------------------------------------------------------------
-- ZOOM VIDEO TOGGLE
--------------------------------------------------------------------------------

-- App-layer Y sends Cmd+Ctrl+Alt+Shift+F14 to toggle Zoom video.
-- Works even when Zoom is not the active app.
warnIfSystemAssigned(zoomSignalMods, "F14", "Zoom video signal Shift+F14")
hs.hotkey.bind(zoomSignalMods, "F14", function()
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
    hs.eventtap.keyStroke({"cmd", "shift"}, "V")
    hs.timer.usleep(50000) -- Wait 50ms for keystroke
    if currentApp then
      currentApp:activate()
    end
    hs.notify.new({title="Zoom", informativeText="Video toggled"}):send()
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
