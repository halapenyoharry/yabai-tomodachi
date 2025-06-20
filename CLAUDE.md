# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

### Development
```bash
npm run build          # Compile TypeScript to JavaScript
npm run dev           # Run MCP development server
npm run watch         # Watch mode for development
npm run lint          # Run ESLint
npm run test          # Run Jest tests
```

### Testing the MCP Server
```bash
# Run the server directly for testing
node dist/index.js

# For development with auto-reload
npm run watch
```

## Architecture Overview

This is a Model Context Protocol (MCP) server that provides programmatic control over the Yabai window manager on macOS.

### Core Components

**MCP Server (`src/index.ts`)**
- Implements 12 tools for Yabai control via JSON-RPC
- Uses stdio transport for MCP communication
- Executes Yabai commands via shell (`yabai` CLI)
- All tools return structured JSON responses

**Tool Categories:**
1. Query Operations: `query_spaces`, `query_windows`, `query_displays`
2. Window Management: `focus_window`, `move_window_to_space`, `resize_window`, `toggle_window_property`
3. Space Management: `create_space`, `destroy_space`, `label_space`, `set_space_layout`, `focus_space`

### Yabai Restarter Menu Bar App

`YabaiRestarter.swift` - Simple menu bar app for restarting Yabai when it gets stuck:
```bash
# Run directly
./YabaiRestarter.swift

# Or compile first
swiftc YabaiRestarter.swift -o YabaiRestarter
./YabaiRestarter
```

Features:
- Restart/Stop/Start Yabai service
- Reload Yabai configuration
- Quick layout switching (BSP/Float/Stack)

### Archived Menu Bar Implementations

Experimental menu bar clients have been moved to `old/` directory. These were early explorations toward a universal MCP menu bar concept.

## Development Patterns

### Adding New Tools
1. Define the tool in `mcp.json` with proper schema
2. Implement the handler in `src/index.ts` following existing patterns
3. Use `runYabaiCommand()` utility for shell execution
4. Return structured responses with error handling

### Error Handling
- All tools wrap Yabai commands in try-catch blocks
- Return descriptive error messages in the response
- Log errors to stderr for debugging

### Testing Yabai Commands
Before implementing, test commands directly:
```bash
yabai -m query --spaces
yabai -m window --focus north
yabai -m space --layout bsp
```

## Universal MCP Vision

This project is part of a larger vision to transform MCP from an AI-specific protocol to a general-purpose tool access system. The universal menu bar would:
- Discover all MCP servers on the system
- Provide GUI access to MCP tools outside of AI contexts
- Enable automation and scripting with MCP tools
- Make MCP servers useful for everyday workflows

## MCP Server Setup

The MCP server is configured in Claude Desktop's config at:
`~/Library/Application Support/Claude/claude_desktop_config.json`

Entry name: `yabai-tomodachi`

**Note**: On slower Macs, Yabai operations through MCP can be slow. The menu bar app provides instant access to common commands while the MCP server is better suited for future Mac Studio setups.