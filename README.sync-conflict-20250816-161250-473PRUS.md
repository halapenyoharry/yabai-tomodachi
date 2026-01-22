# yabai-tomodachi 🌙

<p align="center">
  <img src="icons/YabaiTomodachi.png" width="256" alt="yabai-tomodachi Icon">
</p>

<p align="center">
  <b>Liberation Technology for macOS Window Management</b><br>
  <i>Ambient consciousness computing through <a href="https://github.com/koekeishiya/yabai">Yabai</a> + AI integration</i>
</p>

## 🙏 A Tribute to koekeishiya's Yabai

Yabai is a masterpiece of software engineering that transforms macOS window management. Its creator, koekeishiya, deserves the highest praise for building a tool that reduces cognitive overhead by 20-30% when multitasking on macOS. If there were a Nobel Prize for macOS applications, Yabai would win it for all time. 

yabai-tomodachi exists to make this incredible power more accessible and friendly.

## 🎯 What is yabai-tomodachi?

yabai-tomodachi is a companion app that helps you get the most out of yabai. Think of it as your friendly guide to window management mastery.

### Currently Includes:

**🖱️ Menu Bar App**
- Instant access to essential Yabai commands
- Restart Yabai when it gets stuck (the #1 user request!)
- Quick layout switching without memorizing commands
- Visual access to window controls

**🤖 AI Integration (MCP Server)**
- Natural language window management through Claude
- Query and control windows programmatically
- Build automated workspace workflows
- Future-proof your window management

### Coming Soon:
- Keyboard shortcut manager
- Visual layout designer
- Workspace presets
- And more based on community feedback!

## 🚀 Features

**v1.5 Liberation Technology Edition:**

**🎯 Zero-Friction Installation:**
- **One-Click Install**: Double-click .pkg, everything works
- **Bundled Dependencies**: Includes yabai v7.1.15, no external setup
- **Silent Operations**: No terminal windows, no scary messages
- **Claude Integration**: Desktop extension auto-installed

**🖱️ Clean Menu Bar App:**
- **Service Management**: Restart, stop, start Yabai instantly
- **Window Controls**: Balance, float, fullscreen, split, center
- **Layout Switching**: BSP (tiling), float, stack modes
- **Space Management**: Rotate, mirror, adjust gaps/padding
- **Quick Actions**: Edit config, reload settings, restart Dock

**🤖 AI-Powered Window Management:**
- **Claude Integration**: "Move this window to space 2", "Switch to tiling"
- **Window Awareness**: AI sees all your windows and their context
- **Natural Language**: Tell Claude what workspace you want
- **Real-time Control**: Instant window management through conversation

## 🛠 Installation

### v1.5 Quick Install (Recommended)

**Requirements:**
- macOS 12.0+ (Monterey or later)
- Admin password for installation

**Steps:**
1. **Download**: Get `yabai-tomodachi-1.5.0.pkg`
2. **Install**: Double-click the package file  
3. **Done**: Menu bar app appears, Claude can control your windows

**What gets installed:**
- ✅ Yabai v7.1.15 (bundled, no Homebrew needed)
- ✅ Menu bar app with clean interface
- ✅ Claude Desktop extension for AI control
- ✅ Default yabai configuration
- ✅ Auto-configured services

**Zero configuration required. Just works.** 🌙

### Installing Yabai (if you haven't already)

yabai-tomodachi needs [yabai](https://github.com/koekeishiya/yabai) to work its magic. Here's the quick install:

```bash
# Install Yabai via Homebrew
brew install koekeishiya/formulae/yabai

# Start Yabai
yabai --start-service

# Optional but recommended: Install skhd for keyboard shortcuts
brew install koekeishiya/formulae/skhd
skhd --start-service
```

For detailed Yabai configuration and troubleshooting, check the [official Yabai wiki](https://github.com/koekeishiya/yabai/wiki).

**Quick Install:** We also provide an install script:
```bash
curl -fsSL https://raw.githubusercontent.com/halapenyoharry/yabai-tomodachi/main/install-yabai.sh | bash
```

### Advanced Features (Scripting Addition)

Some of Yabai's most powerful features require the scripting addition:
- **Window Opacity** - Make windows transparent
- **Focus Follows Mouse** - Focus windows by hovering
- **Window Animations** - Smooth transitions
- **Advanced Space Management** - Better multi-monitor support

yabai-tomodachi can help you install the scripting addition:
1. Click the menu bar icon
2. Go to "Scripting Addition" → "Install Scripting Addition"
3. Follow the prompts

**Note:** The scripting addition requires partially disabling System Integrity Protection (SIP). This is safe but requires a restart into Recovery Mode. yabai-tomodachi will guide you through the process.

### Option 1: Install from Package (Easiest)
Download the latest `yabai-tomodachi-1.0.0.pkg` from the [releases page](https://github.com/halapenyoharry/yabai-tomodachi/releases) and double-click to install.

This installs:
- yabai-tomodachi app to `/Applications`
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

### Window Maximize Behavior

**Note on Maximize vs Traditional Window Managers:**
Unlike traditional window managers (like Pop!_OS), Yabai handles window maximization differently:

- **Traditional behavior**: Double-clicking the titlebar toggles between maximized and restored states
- **Yabai behavior**: Windows are managed by the tiling layout (BSP), which automatically arranges them

To achieve a maximize-like effect in Yabai:
1. Use **"Toggle Maximize"** from the menu bar app (toggles zoom-fullscreen within the BSP layout)
2. Or use **"Toggle Float"** first, then double-click the titlebar for native macOS maximize
3. The zoom-fullscreen approach keeps your window within the tiling system while maximizing it

This design reflects Yabai's philosophy: windows should be managed by the tiling system rather than floating freely.

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

*using all my tokens to make advanced tech creatively available to me and hopefully at least one other person. hi.*

---

*Tomodachi (友達) means "friend" in Japanese. This project aims to be a helpful friend to both Yabai and its users.*