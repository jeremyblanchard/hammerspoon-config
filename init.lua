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

-- Define your apps here - customize these to your needs
-- Format: ["key"] = "Application Name" or "com.bundle.id"

local apps = {
  -- Common apps (customize these!)
  ["H"] = "Google Chrome",
  ["V"] = "Slack",
  ["S"] = "Ghostty",
  ["N"] = "Cursor",
  ["R"] = "1Password",
  ["M"] = "Zoom",
  ["F"] = "Finder",
  ["P"] = "Notion Calendar"
}

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
-- UTILITY FUNCTIONS
--------------------------------------------------------------------------------

-- Get bundle ID of frontmost app (useful for configuration)
-- Run this in Hammerspoon console: hs.application.frontmostApplication():bundleID()

-- Log when config is loaded
print("Hammerspoon config loaded successfully!")
