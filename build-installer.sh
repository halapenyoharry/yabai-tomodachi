#!/bin/bash

# Clean build script for Yabai-Tomodachi installer

VERSION="1.0.0"
PRODUCT_NAME="YabaiTomodachi"

echo "Building Yabai-Tomodachi installer v$VERSION..."

# Create temp directory for clean build
TEMP_DIR=$(mktemp -d)
APP_DIR="$TEMP_DIR/Applications/Yabai-Tomodachi.app"
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

# Copy icon if it exists
if [ -f "YabaiTomodachi.icns" ]; then
    echo "Adding icon..."
    cp YabaiTomodachi.icns "$APP_DIR/Contents/Resources/"
fi

# Copy launch agent
cp installer/Payload/Library/LaunchAgents/com.yabai.tomodachi.plist "$TEMP_DIR/Library/LaunchAgents/"

# Build the package
echo "Building package..."
pkgbuild --root "$TEMP_DIR" \
         --scripts installer/Scripts \
         --identifier com.yabai.tomodachi \
         --version "$VERSION" \
         --install-location / \
         --ownership recommended \
         "${PRODUCT_NAME}-${VERSION}.pkg"

# Clean up
rm -rf "$TEMP_DIR"

echo "Package built: ${PRODUCT_NAME}-${VERSION}.pkg"
echo ""
echo "To install:"
echo "  sudo installer -pkg ${PRODUCT_NAME}-${VERSION}.pkg -target /"
echo ""
echo "Or double-click the .pkg file to use the GUI installer"