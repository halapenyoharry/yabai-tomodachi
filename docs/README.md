# Yabai Tomadachi 🌸

Your friendly window management companion for yabai!

## What is Yabai Tomadachi?

Yabai Tomadachi (友達 = friend) is a companion tool that makes yabai window management more accessible and user-friendly. It provides both a CLI interface and a GUI menu bar app for controlling yabai.

## Features

### CLI Version
- Interactive terminal interface
- Vi-like keybindings (h/j/k/l)
- Quick window focusing and movement
- Window resizing
- Float/fullscreen toggles
- Real-time window and space information

### GUI Version (Electron)
- Menu bar app with quick access
- Global keyboard shortcuts
- Layout presets (Focus Mode, Split View, Grid)
- Visual settings management
- Space navigation
- One-click window arrangements

## Installation

```bash
# Clone the repository
cd /Users/claude/Projects/fix-yabai-tomadachi

# Install dependencies
npm install

# Run CLI version
npm start

# Run GUI version
npm run start:gui
```

## Usage

### CLI Commands
```
h/help     - Show help
w          - Show window info
s          - Show space info

Focus:
←/h        - Focus left window
→/l        - Focus right window  
↑/k        - Focus window above
↓/j        - Focus window below

Move:
H          - Swap with left window
L          - Swap with right window
K          - Swap with window above
J          - Swap with window below

Resize:
<          - Resize smaller
>          - Resize larger

Toggle:
f          - Toggle float
F          - Toggle fullscreen

q          - Quit
```

### GUI Shortcuts
- `Alt+H/J/K/L` - Focus windows
- `Alt+Shift+H/J/K/L` - Move windows
- `Alt+F` - Toggle float
- `Alt+Shift+F` - Toggle fullscreen
- `Alt+Left/Right` - Navigate spaces

## Requirements

- macOS
- [yabai](https://github.com/koekeishiya/yabai) installed and running
- Node.js 14+

## Why Yabai Tomadachi?

Harry loved the simplicity of having a friendly interface to yabai that didn't require memorizing complex commands. This tool brings that vision back to life with:

- 🎯 Focused, simple interface
- 🚀 Quick access to common operations
- 🎨 Visual feedback
- 💪 Power user shortcuts
- 🌸 Friendly and approachable

## Contributing

Feel free to submit issues and enhancement requests!

## License

MIT - Made with ❤️ for Harry