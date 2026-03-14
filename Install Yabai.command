#!/bin/bash
# ============================================================
#  Yabai Tomodachi — Yabai Installer Helper
#  Double-click this file to install yabai via Homebrew.
# ============================================================

set -e

echo ""
echo "  Yabai Tomodachi — Yabai Setup Helper"
echo "  ====================================="
echo ""

# 1. Check for Homebrew
if ! command -v brew &>/dev/null; then
    echo "  Homebrew is not installed."
    echo "  Homebrew is the standard macOS package manager and is required to install yabai."
    echo ""
    echo "  To install Homebrew, visit: https://brew.sh"
    echo "  Or paste this into Terminal:"
    echo ""
    echo '  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    echo ""
    echo "  After installing Homebrew, double-click this file again."
    echo ""
    read -n 1 -s -r -p "  Press any key to exit..."
    exit 1
fi

echo "  [ok] Homebrew found at $(which brew)"

# 2. Check if yabai is already installed
if command -v yabai &>/dev/null; then
    echo "  [ok] yabai is already installed at $(which yabai)"
    echo ""
    YABAI_VERSION=$(yabai --version 2>/dev/null || echo "unknown")
    echo "  Version: $YABAI_VERSION"
else
    echo ""
    echo "  Installing yabai..."
    echo ""
    brew install koekeishiya/formulae/yabai
    echo ""
    echo "  [ok] yabai installed successfully"
fi

# 3. Create default .yabairc if it doesn't exist
YABAIRC="$HOME/.yabairc"
if [ ! -f "$YABAIRC" ]; then
    echo ""
    echo "  Creating default yabai configuration at $YABAIRC..."
    cat > "$YABAIRC" << 'EOF'
#!/usr/bin/env sh

# yabai-tomodachi default configuration
# Feel free to customize! See: https://github.com/koekeishiya/yabai/wiki

# Default layout: bsp (tiling), float, or stack
yabai -m config layout bsp

# New window spawns to the right/bottom
yabai -m config window_placement second_child

# Padding and gaps (adjust with Padding +/- and Gaps +/- in the menu bar app)
yabai -m config top_padding    12
yabai -m config bottom_padding 12
yabai -m config left_padding   12
yabai -m config right_padding  12
yabai -m config window_gap     12

# Mouse settings
yabai -m config mouse_follows_focus off
yabai -m config focus_follows_mouse off
yabai -m config mouse_modifier      fn
yabai -m config mouse_action1       move
yabai -m config mouse_action2       resize

echo "yabai configuration loaded."
EOF
    chmod +x "$YABAIRC"
    echo "  [ok] Default configuration created"
else
    echo "  [ok] Existing configuration found at $YABAIRC"
fi

# 4. Start yabai service
echo ""
echo "  Starting yabai service..."
yabai --start-service 2>/dev/null || true
sleep 1

if pgrep -x yabai >/dev/null; then
    echo "  [ok] yabai is running"
else
    echo "  [!!] yabai may not be running yet."
    echo "  You may need to grant Accessibility permissions first."
fi

# 5. Permissions reminder
echo ""
echo "  ====================================="
echo "  IMPORTANT: Accessibility Permissions"
echo "  ====================================="
echo ""
echo "  yabai needs Accessibility access to manage windows."
echo ""
echo "  1. Open System Settings > Privacy & Security > Accessibility"
echo "  2. Click the + button"
echo "  3. Navigate to $(which yabai) and add it"
echo "  4. Make sure the toggle is ON"
echo ""
echo "  The Yabai Tomodachi menu bar app has a 'Permissions Helper'"
echo "  under More that can guide you through this."
echo ""
echo "  ====================================="
echo "  Setup complete! You can close this window."
echo "  ====================================="
echo ""
read -n 1 -s -r -p "  Press any key to exit..."
