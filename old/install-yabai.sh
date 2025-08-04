#!/bin/bash

# Yabai Installation Helper
# Used by Yabai-Tomadachi when yabai is not found

echo "🌸 Yabai-Tomadachi Installation Helper 🌸"
echo ""
echo "This script will install yabai using Homebrew."
echo ""

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew is not installed!"
    echo ""
    echo "Please install Homebrew first:"
    echo "/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    echo ""
    read -p "Press any key to exit..."
    exit 1
fi

echo "📦 Installing yabai..."
brew install koekeishiya/formulae/yabai

echo ""
echo "🚀 Starting yabai service..."
yabai --start-service

echo ""
echo "✅ Yabai installation complete!"
echo ""
echo "Note: For advanced features, you may need to disable System Integrity Protection (SIP)."
echo "See: https://github.com/koekeishiya/yabai/wiki/Disabling-System-Integrity-Protection"
echo ""
echo "You can now use Yabai-Tomadachi!"
echo ""
read -p "Press any key to continue..."