# Yabai-Tomodachi (Yabai Friend)

A friendly companion toolkit for the incredible [Yabai](https://github.com/koekeishiya/yabai) window manager on macOS.

## 🙏 Tribute to Yabai

Yabai is a masterpiece of software engineering that transforms macOS window management. Its creator, koekeishiya, deserves the highest praise for building a tool that reduces cognitive overhead by 20-30% when multitasking on macOS. If there were a Nobel Prize for macOS applications, Yabai would win it for all time. This project exists to complement and celebrate Yabai's excellence.

## 🎯 What is Yabai-Tomodachi?

Yabai-Tomodachi provides two complementary tools:

1. **YabaiRestarter** - A menu bar app for quick Yabai control
2. **MCP Server** - AI-powered window management through Claude

## 🚀 Features

### YabaiRestarter Menu Bar App
Simple, instant access to essential Yabai commands:

- **Service Control**: Restart, stop, or start Yabai when it gets stuck
- **Window Commands**: Balance, float, fullscreen, split, center windows
- **Layout Control**: Switch between BSP (tiling), float, and stack layouts
- **Space Management**: Rotate, mirror, adjust padding and gaps
- **Quick Actions**: Edit config, reload settings, restart Dock

### MCP Server for AI Integration
Let Claude control your window management:

- Query spaces, windows, and displays
- Move and resize windows programmatically
- Create and manage spaces
- Set layouts and window properties
- Build context-aware workspace automation

## 🛠 Installation

### Prerequisites
- macOS with [Yabai](https://github.com/koekeishiya/yabai) installed
- Node.js v16+ (only for MCP server development)
- Swift (comes with macOS, only for building from source)

### Option 1: Install from Package (Easiest)
Download the latest `YabaiTomodachi-1.0.0.pkg` from the [releases page](https://github.com/halapenyoharry/yabai-tomodachi/releases) and double-click to install.

This installs:
- YabaiRestarter app to `/Applications`
- Launch agent (disabled by default)

To auto-start at login:
```bash
launchctl load ~/Library/LaunchAgents/com.yabai.tomodachi.plist
```

### Option 2: Build from Source

1. Clone the repository:
```bash
git clone https://github.com/halapenyoharry/yabai-tomodachi.git
cd yabai-tomodachi
```

2. Run the menu bar app:
```bash
./YabaiRestarter.swift
# Or compile it first:
swiftc YabaiRestarter.swift -o YabaiRestarter
./YabaiRestarter
```

3. For MCP integration with Claude:
```bash
npm install
npm run build
```

Add to Claude Desktop config (`~/Library/Application Support/Claude/claude_desktop_config.json`):
```json
{
  "mcpServers": {
    "yabai-tomodachi": {
      "command": "node",
      "args": ["/path/to/yabai-tomodachi/dist/index.js"]
    }
  }
}
```

## 💡 Usage Examples

### Menu Bar App
Click the menu bar icon to:
- Quickly restart Yabai when windows get stuck
- Switch layouts on the fly
- Balance window sizes
- Adjust gaps and padding

### Claude Integration
Tell Claude things like:
- "Set up my workspace for React development"
- "Move all browsers to space 2"
- "Make the current window float"
- "Balance all windows on this space"
- "Create a new space for documentation"

## 🎨 The Vision

Imagine AI that understands your workspace:
- Automatically arranges windows based on your current task
- Moves documentation to one screen, code to another
- Hides distracting apps when you need to focus
- Saves and restores project-specific layouts
- Responds to natural language workspace requests

## 📝 MCP Tools Available

The MCP server provides 12 tools:

### Query Operations
- `query_spaces` - Get information about all spaces
- `query_windows` - Query windows with filters
- `query_displays` - Get display information

### Window Management
- `focus_window` - Focus by direction or ID
- `move_window_to_space` - Move windows between spaces
- `resize_window` - Resize by pixels
- `toggle_window_property` - Toggle float, sticky, etc.

### Space Management
- `create_space` - Create new spaces
- `destroy_space` - Remove spaces
- `label_space` - Name your spaces
- `set_space_layout` - Change layout modes
- `focus_space` - Switch to specific spaces

## 🤝 Contributing

Contributions are welcome! This project aims to enhance the Yabai experience while respecting its design philosophy.

## 📄 License

MIT License - Same as Yabai, because we believe in the same principles of open software.

## 🙏 Acknowledgments

- **koekeishiya** - Creator of Yabai, the foundation this project builds upon
- The Yabai community for continuous inspiration
- Anthropic for the MCP protocol that enables AI integration

---

*Tomodachi (友達) means "friend" in Japanese. This project aims to be a helpful friend to both Yabai and its users.*