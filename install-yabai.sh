#!/bin/bash

# Yabai-Tomodachi Yabai Installer
# This script helps install Yabai for users who don't have it yet

echo "🪟 Yabai-Tomodachi Yabai Installer"
echo "=================================="
echo ""

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew is not installed!"
    echo "Please install Homebrew first: https://brew.sh"
    echo "Run: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
fi

# Check if Yabai is already installed
if command -v yabai &> /dev/null; then
    echo "✅ Yabai is already installed!"
    yabai --version
    echo ""
    echo "Would you like to restart Yabai? (y/n)"
    read -r response
    if [[ "$response" == "y" ]]; then
        yabai --restart-service
        echo "✅ Yabai restarted!"
    fi
    exit 0
fi

# Install Yabai
echo "📦 Installing Yabai..."
brew install koekeishiya/formulae/yabai

# Start Yabai service
echo "🚀 Starting Yabai service..."
yabai --start-service

# Ask about skhd
echo ""
echo "Would you like to install skhd for keyboard shortcuts? (y/n)"
read -r response
if [[ "$response" == "y" ]]; then
    echo "📦 Installing skhd..."
    brew install koekeishiya/formulae/skhd
    skhd --start-service
    echo "✅ skhd installed and started!"
fi

echo ""
echo "✅ Yabai installation complete!"
echo ""
echo "🎉 You can now use Yabai-Tomodachi!"
echo ""
echo "Note: You may need to grant accessibility permissions to Yabai."
echo "Go to: System Preferences > Security & Privacy > Privacy > Accessibility"
echo "And add Yabai to the allowed apps."