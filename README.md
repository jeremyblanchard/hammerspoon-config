# Hammerspoon Configuration

Personal Hammerspoon configuration for macOS automation, window management, and app switching.

## Features

- **Smooth Scrolling**: Keyboard-based scrolling with `Ctrl+Cmd+Opt+Arrow` keys
- **Window Management**: Move windows between monitors with `Alt+Ctrl+Up/Down`
- **App Switching**: Press `Hyper+Space`, release, then press an app key to launch or focus it
- **Zoom Audio Toggle**: `Hyper+E` maps to `Cmd+Shift+A` for Zoom's native global mute/unmute shortcut
- **Zoom Video Toggle**: `Hyper+Y` toggles Zoom video without leaving the current app
- **True Hyper**: The keyboard's held Tab key sends `Cmd+Ctrl+Alt+Shift`
- **Config Reload**: `Cmd+Alt+Ctrl+R` to reload configuration

## Installation

1. Install [Hammerspoon](https://www.hammerspoon.org/)
2. Clone this repo:
   ```bash
   git clone <your-repo-url> ~/.hammerspoon
   ```
3. Create `machine-local.lua` to set your profile:
   ```bash
   cd ~/.hammerspoon
   cat > machine-local.lua << 'EOF'
   return { profile = "work" }  -- or "personal"
   EOF
   ```
4. Open Hammerspoon and enable accessibility permissions
5. Reload config with `Cmd+Alt+Ctrl+R`

## Customization

### App Shortcuts (Machine-Specific)

Edit `apps-work.lua` or `apps-personal.lua`:
```lua
return {
  ["H"] = "Google Chrome",  -- Hyper+Space, then H
  ["T"] = "Slack",          -- Hyper+Space, then T
  -- Add more apps...
}
```

### Scroll Speed

Edit `scroll.lua` to adjust:
- `scrollSpeed` - Lines per scroll (default: 3)
- `scrollDelay` - Time between scrolls (default: 0.03s)

### Other Settings

Edit `init.lua` to customize window management, hotkeys, and add your own automation

## Multi-Machine Setup

This config supports different app mappings per computer while sharing behaviors.

### What's Synced (Git)
- `init.lua` - Main configuration
- `scroll.lua` - Scroll behavior
- `apps-work.lua` - Work computer app mappings
- `apps-personal.lua` - Personal computer app mappings

### What's Local (Not Synced)
- `machine-local.lua` - Profile selector (gitignored)

### Workflow

**After making changes:**
```bash
cd ~/.hammerspoon
git add .
git commit -m "Update config"
git push
```

**On other computers:**
```bash
cd ~/.hammerspoon
git pull
# machine-local.lua stays unchanged (keeps your profile)
```

Reload: `Cmd+Alt+Ctrl+R`

### Adding a New Profile

1. Create `apps-{name}.lua`
2. Set `profile = "{name}"` in `machine-local.lua`
3. Commit and push the new apps file
