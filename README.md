# Hammerspoon Configuration

Personal Hammerspoon configuration for macOS automation, window management, and app switching.

## Features

- **Window Management**: Move windows between monitors with `Alt+Ctrl+Up/Down`
- **App Switching**: Quick app launcher with `Cmd+Alt+[Key]`
- **Toggle Apps**: Hide/show apps with `Cmd+Alt+Shift+[Key]`
- **Config Reload**: `Cmd+Alt+Ctrl+R` to reload configuration

## Installation

1. Install [Hammerspoon](https://www.hammerspoon.org/)
2. Clone this repo:
   ```bash
   git clone <your-repo-url> ~/.hammerspoon
   ```
3. Open Hammerspoon and enable accessibility permissions
4. Reload config with `Cmd+Alt+Ctrl+R`

## Customization

Edit `init.lua` to customize:
- App shortcuts in the `apps` table (line ~47)
- Window management shortcuts (lines ~20-38)
- Add your own automation

## Syncing Across Computers

After making changes:
```bash
cd ~/.hammerspoon
git add .
git commit -m "Update config"
git push
```

On other computers:
```bash
cd ~/.hammerspoon
git pull
```

Then reload Hammerspoon with `Cmd+Alt+Ctrl+R`.
