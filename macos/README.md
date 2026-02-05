# macOS

Configures macOS settings, including user preferences, installing Homebrew and applications. Run after initial macOS out-of-box setup.

Run via:

```shell
chmod +x ./oobe.sh
./oobe.sh
```

## Settings and Configurations

The `oobe.sh` script configures the following macOS settings:

### System

- macOS software updates
- Installed Homebrew package manager
- Login window message set to a Back to the Future reference

### Hostname & Model-Specific Settings

- **Mac mini**: Computer name set to "Marty"
- **MacBook Air**: Computer name set to "Einstein"
  - Software video decoder enabled
  - Battery percentage displayed in control center

### Dock

- Tile size: 46
- Auto-hide enabled with 0.5s animation
- App Exposé gesture enabled
- All file extensions shown

### Finder

- Path bar enabled
- Folders sorted first
- Default search scope set to current folder
- Extension change warnings disabled
- Larger icon sizes (size mode 3)
- Desktop folders sorted first
- Column auto-sizing enabled
- New windows open to home folder
- Toolbar configured with Back, Switch, Arrange, Share, Actions, and Search buttons

### Trackpad & Input

- Drag lock enabled
- Three-finger drag enabled
- Smart quotes disabled in TextEdit
- Click-to-show-desktop disabled

### Visual & Display

- Spaces: Disabled spanning displays
- Screenshots: Saved to ~/Pictures/Screenshots with thumbnails disabled
- Widgets: Set to light mode appearance

### Privacy & Storage

- .DS_Store files disabled on network and USB volumes
- Spotlight related content disabled
- iCloud-related preference disabled

### Shell Configuration

- **Zsh**: oh-my-zsh installed with agnoster theme
  - Aliases: cls, dir, drink
  - Environment variables configured
  - Default working directory set to ~/projects

### PowerShell

- PowerShell profile copied to ~/.config/powershell/

### Terminal

- Terminal preferences imported from TerminalPreferences.plist

### Applications

- Homebrew bundles installed based on machine model:
  - Mac mini: Macmini-Brewfile.txt
  - MacBook Air: MacBookAir-Brewfile.txt
- Dock apps configured: Safari, Microsoft Edge, Calendar, Visual Studio Code, Terminal

### Directories

- ~/projects
- ~/Virtual Machines

## Sources

* https://mac.install.guide/mac-setup/
* https://github.com/donnybrilliant/install.sh/tree/main
* https://macos-defaults.com
* https://ss64.com/mac/syntax-defaults.html
* https://emmer.dev/blog/automate-your-macos-defaults/
* https://mikefrobbins.com/2025/05/07/customize-and-automate-a-clean-macos-dock-layout/
* https://github.com/kevinSuttle/macOS-Defaults/blob/master/.macos
