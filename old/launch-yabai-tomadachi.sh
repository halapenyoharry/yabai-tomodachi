#!/bin/bash

# Yabai Tomadachi Launcher
# Launches the menu bar app and optionally the MCP server

echo "🌸 Launching Yabai Tomadachi..."

# Check if yabai is running
if ! pgrep -x "yabai" > /dev/null; then
    echo "⚠️  Yabai is not running!"
    echo "Would you like to start yabai? (y/n)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        yabai --start-service
        echo "✅ Yabai started"
    fi
fi

# Launch the menu bar app
if [ -f "./YabaiTomadachi" ]; then
    echo "🖱️  Starting menu bar app..."
    ./YabaiTomadachi &
    MENUBAR_PID=$!
    echo "✅ Menu bar app started (PID: $MENUBAR_PID)"
else
    echo "⚠️  Menu bar app not found. Building..."
    swiftc src/YabaiRestarter.swift -o YabaiTomadachi
    ./YabaiTomadachi &
    MENUBAR_PID=$!
    echo "✅ Menu bar app built and started (PID: $MENUBAR_PID)"
fi

# Ask about MCP server
echo ""
echo "Would you like to enable AI integration (MCP server)? (y/n)"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    echo "🤖 Starting MCP server..."
    npm run start:mcp &
    MCP_PID=$!
    echo "✅ MCP server started (PID: $MCP_PID)"
    echo ""
    echo "📝 To use with Claude Desktop, add this to your config:"
    echo "   ~/Library/Application Support/Claude/claude_desktop_config.json"
    echo ""
    echo "{"
    echo "  \"mcpServers\": {"
    echo "    \"yabai-tomadachi\": {"
    echo "      \"command\": \"node\","
    echo "      \"args\": [\"$(pwd)/dist/index.js\"]"
    echo "    }"
    echo "  }"
    echo "}"
fi

echo ""
echo "🎉 Yabai Tomadachi is ready!"
echo "Look for the icon in your menu bar."
echo ""
echo "Press Ctrl+C to stop all services."

# Wait for interrupt
trap 'echo "👋 Stopping Yabai Tomadachi..."; kill $MENUBAR_PID 2>/dev/null; kill $MCP_PID 2>/dev/null; exit' INT
wait