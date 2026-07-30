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
-- position sends a synthetic shortcut using F13 through F20. The shifted bank
-- provides additional signals because macOS does not expose F21 through F24 as
-- bindable virtual keycodes.
local appSignalMods = {"cmd", "ctrl", "alt"}
local shiftedSignalMods = {"cmd", "ctrl", "alt", "shift"}
local appSignals = {
  ["A"] = {key = "F13", shifted = false},
  ["S"] = {key = "F14", shifted = false},
  ["D"] = {key = "F15", shifted = false},
  ["F"] = {key = "F16", shifted = false},
  ["G"] = {key = "F17", shifted = false},
  ["Z"] = {key = "F18", shifted = false},
  ["X"] = {key = "F19", shifted = false},
  ["C"] = {key = "F20", shifted = false},
  ["V"] = {key = "F15", shifted = true},
  ["B"] = {key = "F16", shifted = true},
  ["O"] = {key = "F17", shifted = true},
  ["L"] = {key = "F18", shifted = true}
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

  local mods = signal.shifted and shiftedSignalMods or appSignalMods
  warnIfSystemAssigned(mods, signal.key, "app signal " .. signal.key)
  hs.hotkey.bind(mods, signal.key, function()
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

warnIfSystemAssigned(shiftedSignalMods, "F13", "Zoom audio signal Shift+F13")
hs.hotkey.bind(shiftedSignalMods, "F13", sendZoomAudioShortcut)

--------------------------------------------------------------------------------
-- ZOOM VIDEO TOGGLE
--------------------------------------------------------------------------------

-- App-layer Y sends Cmd+Ctrl+Alt+Shift+F14 to toggle Zoom video.
-- Works even when Zoom is not the active app.
warnIfSystemAssigned(shiftedSignalMods, "F14", "Zoom video signal Shift+F14")
hs.hotkey.bind(shiftedSignalMods, "F14", function()
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
