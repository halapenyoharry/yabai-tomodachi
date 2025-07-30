# Yabai Tomadachi - RESTORED! 🌸

## Mission Complete: Code Archaeology Success

We successfully restored yabai-tomadachi from the original repository! This version includes:

### ✅ What's Working

1. **Swift Menu Bar App** (Original)
   - Full yabai control from menu bar
   - Service management (restart/stop/start)
   - Window controls (balance, float, fullscreen)
   - Layout switching (BSP, float, stack)
   - Padding and gap controls
   - Auto-detects yabai installation

2. **MCP Server** (TypeScript)
   - 12 tools for AI-powered window management
   - Natural language control via Claude
   - Query windows, spaces, and displays
   - Programmatic window control

3. **Bonus CLI Tools** (New)
   - Interactive terminal interface
   - Vi-like keybindings
   - Electron GUI version

## 🚀 Quick Start

```bash
# One command to rule them all
./launch-yabai-tomadachi.sh
```

This will:
- Check if yabai is running (offer to start it)
- Launch the menu bar app
- Optionally start the MCP server for AI integration

## 📁 Project Structure

```
fix-yabai-tomadachi/
├── YabaiTomadachi          # Compiled Swift menu bar app
├── src/
│   ├── YabaiRestarter.swift # Original Swift menu bar source
│   ├── index.ts            # MCP server main
│   ├── utils.ts            # MCP utilities
│   ├── yabai-tomadachi.js  # Bonus CLI tool
│   └── yabai-tomadachi-gui.js # Bonus Electron GUI
├── dist/                   # Compiled TypeScript
├── icons/                  # Beautiful app icons
└── launch-yabai-tomadachi.sh # Master launcher
```

## 🛠️ Manual Installation

### Menu Bar App Only
```bash
# Compile and run
swiftc src/YabaiRestarter.swift -o YabaiTomadachi
./YabaiTomadachi
```

### MCP Server for Claude
```bash
# Build and configure
npm install
npm run build

# Add to Claude Desktop config:
# ~/Library/Application Support/Claude/claude_desktop_config.json
{
  "mcpServers": {
    "yabai-tomadachi": {
      "command": "node",
      "args": ["/absolute/path/to/dist/index.js"]
    }
  }
}
```

### Bonus CLI Tools
```bash
# Interactive CLI
npm start

# Electron GUI (requires electron)
npm run start:gui
```

## 🎯 Usage

### Menu Bar Features
Click the menu bar icon for:
- **🔄 Restart Yabai** - The #1 requested feature!
- **Window** → Balance, Float, Fullscreen, Split, Center
- **Layout** → BSP, Float, Stack, Rotate, Mirror
- **Padding** → Toggle padding/gaps, adjust sizes
- **Edit Config** - Opens ~/.yabairc
- **Restart Dock** - When things get weird

### AI Commands (via Claude)
With MCP server running:
- "Set up my coding workspace"
- "Move all browsers to space 2"
- "Balance windows on current space"
- "Create a new space for documentation"
- "Make this window float and center it"

## 🔧 Troubleshooting

### Menu bar app doesn't appear
- Check Activity Monitor for YabaiTomadachi
- Try building with: `swiftc src/YabaiRestarter.swift -o YabaiTomadachi`
- Look for build errors

### MCP server issues
- Ensure Node.js 16+ is installed
- Check TypeScript compilation: `npm run build`
- Verify Claude Desktop config path is absolute

### Yabai not responding
- Use menu bar → Restart Yabai
- Check yabai service: `yabai --start-service`
- Review yabai config: `cat ~/.yabairc`

## 📝 Development

### Building from source
```bash
# Swift app
swiftc src/YabaiRestarter.swift -o YabaiTomadachi

# TypeScript MCP
npm install
npm run build

# Watch mode for MCP development
npm run dev
```

### Testing MCP tools
```bash
# Run MCP server in stdio mode
node dist/index.js

# Send test commands via stdio
```

## 🙏 Credits

- Original yabai-tomadachi by halapenyoharry
- Yabai by koekeishiya - the foundation of everything
- Restored with ❤️ using code archaeology

---

*Harry loved this tool, and now it lives again!*