#!/bin/bash

# Yabai Tomadachi Launcher

# Check if yabai is running
if ! pgrep -x "yabai" > /dev/null; then
    echo "⚠️  Yabai is not running!"
    echo "Please start yabai first: yabai --start-service"
    exit 1
fi

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install
fi

# Make scripts executable
chmod +x src/yabai-tomadachi.js
chmod +x src/yabai-tomadachi-gui.js

# Ask user which version to launch
echo "🌸 Yabai Tomadachi Launcher 🌸"
echo ""
echo "Which version would you like to launch?"
echo "1) CLI - Terminal Interface"
echo "2) GUI - Menu Bar App"
echo ""
read -p "Enter your choice (1 or 2): " choice

case $choice in
    1)
        echo "Starting CLI version..."
        node src/yabai-tomadachi.js
        ;;
    2)
        echo "Starting GUI version..."
        npm run start:gui
        ;;
    *)
        echo "Invalid choice. Please run again and select 1 or 2."
        exit 1
        ;;
esac