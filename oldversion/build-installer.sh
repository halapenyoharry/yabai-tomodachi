#!/bin/bash

# Clean build script for yabai-tomodachi installer

VERSION="1.0.0"
PRODUCT_NAME="YabaiTomodachi"

echo "Building yabai-tomodachi installer v$VERSION..."

# Create temp directory for clean build
TEMP_DIR=$(mktemp -d)
APP_DIR="$TEMP_DIR/Applications/yabai-tomodachi.app"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"
mkdir -p "$TEMP_DIR/Library/LaunchAgents"

# Create Info.plist
cat > "$APP_DIR/Contents/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>Yabai-Tomodachi</string>
    <key>CFBundleIconFile</key>
    <string>YabaiTomodachi</string>
    <key>CFBundleIdentifier</key>
    <string>com.yabai.tomodachi</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>Yabai-Tomodachi</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.14</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

# Compile the Swift app  
echo "Compiling Yabai-Tomodachi..."
swiftc YabaiRestarter.swift -o "$APP_DIR/Contents/MacOS/Yabai-Tomodachi"

# Bundle yabai binary
echo "Bundling yabai binary..."
if [ -f "yabai-binary" ]; then
    cp yabai-binary "$APP_DIR/Contents/MacOS/yabai"
    chmod +x "$APP_DIR/Contents/MacOS/yabai"
    echo "Bundled yabai binary"
else
    echo "Warning: yabai-binary not found - downloading latest..."
    curl -L -o yabai-latest.tar.gz https://github.com/koekeishiya/yabai/releases/download/v7.1.15/yabai-v7.1.15.tar.gz
    tar -xzf yabai-latest.tar.gz
    cp archive/bin/yabai "$APP_DIR/Contents/MacOS/yabai"
    chmod +x "$APP_DIR/Contents/MacOS/yabai"
    rm -rf archive yabai-latest.tar.gz
    echo "Downloaded and bundled yabai binary"
fi

# Copy icon if it exists
if [ -f "YabaiTomodachi.icns" ]; then
    echo "Adding icon..."
    cp YabaiTomodachi.icns "$APP_DIR/Contents/Resources/"
fi

# Copy launch agent
cp installer/Payload/Library/LaunchAgents/com.yabai.tomodachi.plist "$TEMP_DIR/Library/LaunchAgents/"

# Debug: Show what we built
echo "Contents of temp directory:"
find "$TEMP_DIR" -type f | head -10

# Build the package
echo "Building package..."
pkgbuild --root "$TEMP_DIR" \
         --scripts installer/Scripts \
         --identifier com.yabai.tomodachi \
         --version "$VERSION" \
         --install-location / \
         --ownership recommended \
         "${PRODUCT_NAME}-${VERSION}.pkg"

# Debug: Check package contents
echo "Package contents:"
pkgutil --payload-files "${PRODUCT_NAME}-${VERSION}.pkg" | head -10

# Clean up (only after package is built)
rm -rf "$TEMP_DIR"

echo "Package built: ${PRODUCT_NAME}-${VERSION}.pkg"
echo ""
echo "To install:"
echo "  sudo installer -pkg ${PRODUCT_NAME}-${VERSION}.pkg -target /"
echo ""
echo "Or double-click the .pkg file to use the GUI installer"