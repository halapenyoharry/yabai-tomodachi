# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

yabai-tamadachi is a companion app for the yabai window manager on macOS, providing both a menu bar GUI and an MCP (Model Context Protocol) server for AI integration. The project enables AI to have full awareness and control of desktop window management through natural language.

## Build Commands

### Menu Bar App (Swift)
```bash
# Compile the Swift menu bar app with icon support
swiftc src/YabaiRestarter.swift -o yabai-tamadachi

# Create app bundle (required for icon)
mkdir -p yabai-tamadachi.app/Contents/MacOS yabai-tamadachi.app/Contents/Resources
cp yabai-tamadachi yabai-tamadachi.app/Contents/MacOS/
cp YabaiTomodachi.icns yabai-tamadachi.app/Contents/Resources/
# Also create Info.plist with proper CFBundleIconFile reference
```

### MCP Server (TypeScript)
```bash
# Install dependencies
npm install

# Build TypeScript to JavaScript
npm run build

# Watch mode for development
npm run dev
```

### Package Installer
```bash
cd pkg-build
# Build component package
pkgbuild --root yabai-root --identifier com.halapenyoharry.yabai-tamadachi --version 1.0.0 --scripts scripts --install-location / yabai-tamadachi.pkg

# Build distribution package
productbuild --distribution distribution.xml --resources . --package-path . ../yabai-tamadachi-installer.pkg
```

## Architecture

### Core Components

1. **Swift Menu Bar App** (`src/YabaiRestarter.swift`)
   - Provides GUI access to yabai commands
   - Falls back to system icon if YabaiTomodachi.icns not found
   - Auto-initializes BSP layout on start/restart
   - Handles window centering by floating first (grid commands require float mode)

2. **MCP Server** (`src/index.ts`)
   - Exposes 12 yabai tools to AI through Model Context Protocol
   - Enables natural language window management via Claude
   - All yabai commands executed via child process spawning

3. **Package Structure**
   - Single component package (not split into app + yabai binary)
   - Installs to /Applications
   - Includes preinstall script to check for yabai

### Key Design Decisions

- Window centering requires floating the window first before applying grid
- Default BSP layout set in both .yabairc and Swift app to avoid confusion
- MCP server is optional - menu bar app works standalone
- Icon assets in `assets/YabaiTomodachi.iconset/` must be converted to .icns

## Critical Naming

**IMPORTANT**: The project name is "yabai-tamadachi" (not "tomadachi" or any variation). This precise naming must be maintained everywhere - in code, packages, and documentation.

## yabai Integration

The app expects yabai at `/opt/homebrew/bin/yabai` or `/usr/local/bin/yabai`. All yabai commands are executed through shell spawning. The app checks for yabai installation on startup and offers to guide installation if missing.

Default yabai configuration (`.yabairc`) sets:
- BSP layout
- 12px padding and gaps
- Mouse modifier: fn key