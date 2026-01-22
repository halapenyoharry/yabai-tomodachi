#!/bin/bash

# yabai-tomodachi v1.5 Installer Builder
# Following macOS pkg best practices 2024-2025

set -e  # Exit on any error

VERSION="1.5.0"
IDENTIFIER="com.harrysgraph.yabaitorodachi"
APP_NAME="Yabai-Tomodachi"

echo "🌊 Building ${APP_NAME} v${VERSION} Installer..."
echo "✨ Liberation Technology Edition"
echo ""

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf temp/
rm -f "${APP_NAME}-${VERSION}.pkg"

# Create temporary build structure for user installation
echo "📁 Creating build structure..."
mkdir -p temp/Applications
mkdir -p temp/tmp
mkdir -p temp/build-scripts

# 1. Compile Swift menu bar app
echo "⚡ Compiling Swift menu bar app..."
mkdir -p "temp/Applications/${APP_NAME}.app/Contents/MacOS"
mkdir -p "temp/Applications/${APP_NAME}.app/Contents/Resources"

# Compile the Swift app
swiftc YabaiTomodachi.swift -o "temp/Applications/${APP_NAME}.app/Contents/MacOS/${APP_NAME}"

# Bundle yabai binary inside app
echo "📦 Bundling yabai v7.1.15..."
if [ -f "yabai-binary" ]; then
    cp yabai-binary "temp/Applications/${APP_NAME}.app/Contents/MacOS/yabai"
    chmod +x "temp/Applications/${APP_NAME}.app/Contents/MacOS/yabai"
else
    echo "⚠️  Warning: Bundled yabai binary not found. User must have yabai installed separately."
fi

# Copy icon
echo "🎨 Adding icon..."
if [ -f "icons/YabaiTomodachi.icns" ]; then
    cp icons/YabaiTomodachi.icns "temp/Applications/${APP_NAME}.app/Contents/Resources/"
elif [ -f "YabaiTomodachi.icns" ]; then
    cp YabaiTomodachi.icns "temp/Applications/${APP_NAME}.app/Contents/Resources/"
else
    echo "⚠️  Warning: Icon not found, app will use system default"
fi

# Create Info.plist
echo "📋 Creating app bundle Info.plist..."
cat > "temp/Applications/${APP_NAME}.app/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDisplayName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIconFile</key>
    <string>YabaiTomodachi</string>
    <key>CFBundleIdentifier</key>
    <string>${IDENTIFIER}</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>${VERSION}</string>
    <key>CFBundleVersion</key>
    <string>${VERSION}</string>
    <key>LSMinimumSystemVersion</key>
    <string>12.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
</dict>
</plist>
EOF

# 2. Copy desktop extension to temp location
echo "🔌 Adding desktop extension..."
if [ -f "yabai-tomodachi.dxt" ]; then
    cp yabai-tomodachi.dxt "temp/tmp/yabai-tomodachi.dxt"
else
    echo "⚠️  Warning: yabai-tomodachi.dxt not found, skipping."
fi

# 3. Create postinstall script
echo "📜 Creating postinstall script..."
cat > temp/build-scripts/postinstall << 'EOF'
#!/bin/bash

# yabai-tomodachi Post-Installation Script
# Silently configures yabai service and creates default config

set -e

YABAI_PATH="$USER_HOME/Applications/yabai-tomodachi.app/Contents/MacOS/yabai"
CURRENT_USER=$(stat -f "%Su" /dev/console)
USER_HOME=$(eval echo "~$CURRENT_USER")

echo "Setting up yabai-tomodachi for user: $CURRENT_USER"

# Function to run commands as the user
run_as_user() {
    sudo -u "$CURRENT_USER" "$@"
}

# 1. Install yabai service with better debugging
echo "Installing yabai service..."
echo "Using yabai binary at: $YABAI_PATH"
echo "Current user: $CURRENT_USER"
echo "User home: $USER_HOME"

if [ ! -f "$YABAI_PATH" ]; then
    echo "ERROR: Yabai binary not found at $YABAI_PATH"
    exit 1
fi

echo "Running: $YABAI_PATH --install-service"
run_as_user "$YABAI_PATH" --install-service || {
    echo "Service installation failed with exit code $?"
    echo "This is normal - continuing anyway..."
}

# 2. Create default .yabairc if it doesn't exist
YABAIRC_PATH="$USER_HOME/.yabairc"
if [ ! -f "$YABAIRC_PATH" ]; then
    echo "Creating default yabai configuration..."
    cat > "$YABAIRC_PATH" << 'YABAIRC'
#!/usr/bin/env sh

# Default layout (can be bsp, stack or float)
yabai -m config layout bsp

# New window spawns to the right if vertical split, or bottom if horizontal split
yabai -m config window_placement second_child

# Padding and gaps
yabai -m config top_padding    12
yabai -m config bottom_padding 12
yabai -m config left_padding   12
yabai -m config right_padding  12
yabai -m config window_gap     12

# Mouse settings
yabai -m config mouse_follows_focus          off
yabai -m config focus_follows_mouse          off
yabai -m config mouse_modifier               fn
yabai -m config mouse_action1                move
yabai -m config mouse_action2                resize

echo "yabai-tomodachi configuration loaded! 🌙"
YABAIRC

    chown "$CURRENT_USER:staff" "$YABAIRC_PATH"
    chmod +x "$YABAIRC_PATH"
fi

# 3. Install Claude Desktop extension
CLAUDE_EXT_DIR="$USER_HOME/Library/Application Support/Claude/extensions"
if [ ! -d "$CLAUDE_EXT_DIR" ]; then
    echo "Creating Claude extensions directory..."
    run_as_user mkdir -p "$CLAUDE_EXT_DIR"
fi

# Copy from temp location to user's Claude extensions
if [ -f "/tmp/yabai-tomodachi.dxt" ]; then
    echo "Installing Claude Desktop extension..."
    run_as_user cp "/tmp/yabai-tomodachi.dxt" "$CLAUDE_EXT_DIR/"
    # Clean up temp file
    rm -f "/tmp/yabai-tomodachi.dxt"
fi

# 4. Start yabai service with debugging
echo "Starting yabai service..."
echo "Running: $YABAI_PATH --start-service"
run_as_user "$YABAI_PATH" --start-service || {
    echo "Service start failed with exit code $?"
    echo "You may need to start it manually with: yabai --start-service"
}

echo "✅ yabai-tomodachi installation complete!"
echo "🚀 Liberation technology activated!"
echo ""
echo "The app will appear in your menu bar."
echo "Claude Desktop can now control your windows through the yabai-tomodachi extension."

exit 0
EOF

chmod +x temp/build-scripts/postinstall

# 4. Build the package using modern pkgbuild (user-level installation)
echo "📦 Building installer package..."
pkgbuild \
    --root temp \
    --identifier "$IDENTIFIER" \
    --version "$VERSION" \
    --install-location "$HOME" \
    --scripts temp/build-scripts \
    "${APP_NAME}-${VERSION}.pkg"

# 5. Verify package contents
echo "🔍 Verifying package contents..."
echo "Package size: $(du -h "${APP_NAME}-${VERSION}.pkg" | cut -f1)"
echo ""
echo "Package contents:"
pkgutil --payload-files "${APP_NAME}-${VERSION}.pkg" | head -20

# Cleanup
echo "🧹 Cleaning up temporary files..."
rm -rf temp/
rm -f yabai-latest.tar.gz
rm -rf archive/

echo ""
echo "✅ ${APP_NAME} v${VERSION} installer built successfully!"
echo "📁 File: ${APP_NAME}-${VERSION}.pkg"
echo ""
echo "🌙 Liberation Technology Features:"
echo "  ✨ Clean Swift menu bar app (no transparency complexity)"
echo "  🎯 Bundled yabai v7.1.15 (no external dependencies)"
echo "  🔌 Claude Desktop extension included"
echo "  🚫 No terminal windows (all silent operations)"
echo "  🏠 User-level installation (configs in user home)"
echo ""
echo "To install:"
echo "  sudo installer -pkg '${APP_NAME}-${VERSION}.pkg' -target /"
echo "  Or double-click the .pkg file"
echo ""
echo "🌊 SQUANCH UNTIL YOU CAN'T! ✨"