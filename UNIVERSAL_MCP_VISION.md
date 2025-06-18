# Universal MCP Menu Bar - Vision Document

## Concept

A universal menu bar application that automatically discovers and provides access to ALL MCP servers on a computer through a single, unified interface. This would transform MCP from an AI-specific protocol into a general-purpose tool access system.

## Why This Would Be Helpful

### 1. **Instant Tool Access**
- Access any MCP tool from any server without opening Claude Desktop
- No need to type commands or remember syntax
- Visual discovery of available capabilities

### 2. **Power User Workflows**
- Create favorites and shortcuts for frequently used tools
- Chain multiple tools together into workflows
- Assign global keyboard shortcuts to specific tools

### 3. **Developer Benefits**
- Test MCP servers during development without AI
- Debug tool implementations with immediate feedback
- Monitor which servers are running and their status

### 4. **Universal Tool Protocol**
- Demonstrates MCP as a general protocol, not just for AI
- Any app could expose functionality via MCP
- Standardized way to access system capabilities

## Proposed Features

### Core Functionality
- Auto-discovery of all MCP servers from Claude config
- Dynamic menu generation based on available tools
- Real-time connection status for each server
- Tool execution with parameter input dialogs

### Organization
- Group tools by server
- Category-based organization within servers
- Search/filter across all tools
- Recently used tools section

### Advanced Features
- **Favorites System**: Pin frequently used tools
- **Tool Chains**: Combine multiple tools into workflows
- **Output Handling**: Display results in notifications/windows
- **Input Templates**: Save common parameter combinations
- **Keyboard Shortcuts**: Global hotkeys for any tool

## Technical Architecture

```
Universal MCP Menu Bar
├── MCP Discovery Engine
│   ├── Config Parser (claude_desktop_config.json)
│   ├── Server Connection Manager
│   └── Tool Inventory System
├── Menu Generation
│   ├── Dynamic Menu Builder
│   ├── Category Organizer
│   └── Favorites Manager
├── Tool Execution
│   ├── Parameter Collection UI
│   ├── JSON-RPC Client
│   └── Result Display
└── User Features
    ├── Search/Filter
    ├── Shortcuts Manager
    └── Workflow Builder
```

## Example Use Cases

### Quick Actions
- Toggle Yabai window float with one click
- Play/pause Spotify from menu bar
- Create GitHub issue without leaving current app
- Search Obsidian notes instantly

### Developer Workflows
- Run test suite via XcodeBuild MCP
- Check git status across multiple repos
- Execute database queries quickly
- Monitor system resources

### Automation
- Morning routine: Open specific apps, arrange windows, start music
- Project setup: Clone repo, install dependencies, open in editor
- End of day: Close apps, save work, update task lists

## Implementation Phases

### Phase 1: Basic Discovery & Display ✓
- Parse Claude config
- Connect to all servers
- Display available tools in menu

### Phase 2: Tool Execution
- Parameter input dialogs
- Execute tools with arguments
- Display results

### Phase 3: User Features
- Favorites system
- Search functionality
- Keyboard shortcuts

### Phase 4: Advanced Features
- Tool chains/workflows
- Custom categories
- Export/import configurations

## Benefits to the MCP Ecosystem

1. **Increased Adoption**: Makes MCP tools accessible to non-AI users
2. **Tool Discovery**: Users can see what's possible with MCP
3. **Testing Ground**: Developers can test servers more easily
4. **Standardization**: Encourages consistent tool design

## Conclusion

This universal menu bar would transform MCP from a Claude-specific feature into a general-purpose tool protocol for macOS. It would make powerful automation accessible to everyone while demonstrating the versatility of the MCP architecture.

---

*Note: The basic proof-of-concept is already implemented in `universal-mcp-menubar/`. This vision document outlines the full potential of the concept.*