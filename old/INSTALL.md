# Yabai Tomadachi Installation Guide

## Prerequisites
- macOS
- Node.js (>= 14.0.0)
- yabai window manager installed and running

## Installation

1. Clone this repository:
```bash
git clone <repository-url>
cd fix-yabai-tomadachi
```

2. Install dependencies:
```bash
npm install
```

3. Make scripts executable:
```bash
chmod +x src/yabai-tomadachi.js
chmod +x src/yabai-tomadachi-gui.js
```

4. (Optional) Create symlinks for global access:
```bash
npm link
```

## Usage

### CLI Version
```bash
# Run directly
node src/yabai-tomadachi.js

# Or if you used npm link
yabai-tomadachi
```

### GUI Version (Menu Bar App)
```bash
# Run directly
npm run start:gui

# Or if you used npm link
yabai-tomadachi-gui
```

## Features

### CLI Version
- Interactive terminal interface
- Vi-like keybindings for window management
- Real-time window and space information
- Direct yabai command execution

### GUI Version
- Menu bar application
- Global keyboard shortcuts
- Layout presets (Focus Mode, Split View, Grid Layout)
- Visual settings configuration
- Easy space management

## Troubleshooting

If you get "yabai is not running" error:
1. Make sure yabai is installed: `brew install koekeishiya/formulae/yabai`
2. Start yabai: `yabai --start-service`
3. Check if it's running: `pgrep yabai`

## Uninstall

To remove global symlinks:
```bash
npm unlink
```

To completely remove:
```bash
rm -rf fix-yabai-tomadachi
```