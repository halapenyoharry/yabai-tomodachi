# yabai-tamadachi

<p align="center">
  <img src="assets/installer-welcome-message.rtfd/icon_128x128.png" width="256" height="256" alt="yabai-tamadachi icon">
</p>

<p align="center">Your friendly companion app for the incredibly powerful <a href="https://github.com/koekeishiya/yabai">yabai</a> window manager, and an innovative connector for the power of MCP protocol and yabai</p>

## 🙏 A Tribute to koekeishiya's yabai

The [yabai](https://github.com/koekeishiya/yabai) window manager is a masterpiece of software engineering that transforms macOS window management. Its creator, koekeishiya, deserves the highest praise for building a tool that reduces cognitive overhead by 20-30% when multitasking on macOS. If there were a Nobel Prize for macOS applications, yabai would win it for all time.

yabai-tamadachi exists to make this incredible power more accessible and friendly.

## 🎯 What is yabai-tamadachi?

A companion app that helps you get the most out of [yabai](https://github.com/koekeishiya/yabai). Think of it as your friendly guide to window management mastery.

**Currently Includes:**

**🖱️ Menu Bar App**
- Instant access to essential [yabai](https://github.com/koekeishiya/yabai) commands
- Restart yabai when it gets stuck (the #1 user request!)
- Quick layout switching without memorizing commands
- Visual access to window controls

**🤖 AI Integration (MCP Server)**
- Natural language window management through Claude
- Query and control windows programmatically
- Build automated workspace workflows
- Future-proof your window management

**Coming Soon:**
- Keyboard shortcut manager
- Visual layout designer
- Workspace presets
- And more based on community feedback!

## 🚀 Features

**Essential Controls at Your Fingertips:**
- **Service Management:** Restart, stop, or start [yabai](https://github.com/koekeishiya/yabai) instantly
- **Window Controls:** Balance, float, fullscreen, split, and center windows
- **Layout Switching:** Toggle between BSP (tiling), float, and stack modes
- **Space Management:** Rotate layouts, mirror axes, adjust padding and gaps
- **Quick Actions:** Edit [yabai](https://github.com/koekeishiya/yabai/wiki/Configuration#configuration-file) config, reload settings, even restart the Dock

**AI-Powered Automation:**
- Tell Claude what you want: "Set up my coding workspace"
- Query window information programmatically
- Create complex window arrangements with simple commands
- Build context-aware workspace automation

## 🛠 Installation

### Prerequisites
- macOS 10.14+
- [yabai](https://github.com/koekeishiya/yabai) window manager
- Node.js 16+ (only for MCP server)

### Quick Install

**Option 1: Download Package (Easiest)**

Download `yabai-tamadachi-installer.pkg` from this repository and run it.

**Option 2: Build from Source**

```bash
# Clone and build
git clone https://github.com/halapenyoharry/yabai-tomodachi.git
cd yabai-tomodachi

# Compile menu bar app
swiftc src/YabaiRestarter.swift -o yabai-tamadachi
./yabai-tamadachi
```

### Installing yabai (if needed)

```bash
brew install koekeishiya/formulae/yabai
yabai --start-service
```

For detailed [yabai](https://github.com/koekeishiya/yabai) setup, see the [official wiki](https://github.com/koekeishiya/yabai/wiki).

### MCP Server Setup (for Claude integration)

```bash
# Build TypeScript
npm install
npm run build

# Add to Claude Desktop config
# ~/Library/Application Support/Claude/claude_desktop_config.json
```

Add this to your Claude config:
```json
{
  "mcpServers": {
    "yabai-tamadachi": {
      "command": "node",
      "args": ["/absolute/path/to/yabai-tamadachi/dist/index.js"]
    }
  }
}
```

## 💡 Usage Examples

**Menu Bar App**

Click the menu bar icon to:
- Quickly restart [yabai](https://github.com/koekeishiya/yabai) when windows get stuck
- Switch layouts on the fly
- Balance window sizes
- Adjust gaps and padding

**Claude Integration**

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

**Query Operations**
- `query_spaces` - Get information about all spaces
- `query_windows` - Query windows with filters
- `query_displays` - Get display information

**Window Management**
- `focus_window` - Focus by direction or ID
- `move_window_to_space` - Move windows between spaces
- `resize_window` - Resize by pixels
- `toggle_window_property` - Toggle float, sticky, etc.

**Space Management**
- `create_space` - Create new spaces
- `destroy_space` - Remove spaces
- `label_space` - Name your spaces
- `set_space_layout` - Change layout modes
- `focus_space` - Switch to specific spaces

## 🤝 Contributing

Contributions are welcome! This project aims to enhance the [yabai](https://github.com/koekeishiya/yabai) experience while respecting its design philosophy.

## 📄 License

MIT License - Same as [yabai](https://github.com/koekeishiya/yabai), because we believe in the same principles of open software.

## 🔗 Other yabai Tools

Explore the rich ecosystem of [yabai](https://github.com/koekeishiya/yabai) companion tools:

- **[skhd](https://github.com/koekeishiya/skhd)** - Simple hotkey daemon for macOS (by koekeishiya)
- **[Stackline](https://github.com/AdamWagner/stackline)** - Visual stack indicators for yabai
- **[Spacebar](https://github.com/cmacrae/spacebar)** - Minimal status bar for yabai
- **[YabaiIndicator](https://github.com/xiamaz/YabaiIndicator)** - Simple space indicator for the menu bar
- **[Nero](https://github.com/theurgetosurge/Nero)** - Another yabai companion with focus on simplicity

## 🙏 Acknowledgments

- **[koekeishiya](https://github.com/koekeishiya)** - Creator of [yabai](https://github.com/koekeishiya/yabai), the foundation this project builds upon
- The [yabai community](https://github.com/koekeishiya/yabai/discussions) for continuous inspiration
- Anthropic for the MCP protocol that enables AI integration

---

*Tamadachi (友達) means "friend" in Japanese. This project aims to be a helpful friend to both [yabai](https://github.com/koekeishiya/yabai) and its users.*
