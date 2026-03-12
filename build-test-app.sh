#!/bin/bash
set -e

APP_NAME="Yabai-Tomodachi-Test"
VERSION="1.5.0"
IDENTIFIER="com.halapenyoharry.yabai-tomodachi.test"

echo "Building Test App: ${APP_NAME}.app..."

mkdir -p "${APP_NAME}.app/Contents/MacOS"
mkdir -p "${APP_NAME}.app/Contents/Resources"

# Compile
swiftc YabaiTomodachi.swift -o "${APP_NAME}.app/Contents/MacOS/Yabai-Tomodachi"

# Copy Icon
if [ -f "YabaiTomodachi.icns" ]; then
    cp YabaiTomodachi.icns "${APP_NAME}.app/Contents/Resources/YabaiTomodachi.icns"
fi

# Create Info.plist
cat > "${APP_NAME}.app/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDisplayName</key>
    <string>Yabai Tomodachi</string>
    <key>CFBundleExecutable</key>
    <string>Yabai-Tomodachi</string>
    <key>CFBundleIconFile</key>
    <string>YabaiTomodachi</string>
    <key>CFBundleIdentifier</key>
    <string>${IDENTIFIER}</string>
    <key>CFBundleName</key>
    <string>Yabai Tomodachi</string>
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

echo "✅ App built at ${PWD}/${APP_NAME}.app"
echo "You can run it with: open ${APP_NAME}.app"
