#!/bin/bash
# ============================================================
#  Build Yabai-Tomodachi.dmg for distribution
#  Creates: ad-hoc signed app + README + Install helper
# ============================================================

set -e

VERSION="2.0.0"
APP_NAME="Yabai-Tomodachi"
DMG_NAME="${APP_NAME}-${VERSION}"
DMG_DIR="dmg-staging"

echo ""
echo "  Building ${APP_NAME} v${VERSION} DMG..."
echo ""

# Clean previous builds
rm -rf "$DMG_DIR" "${DMG_NAME}.dmg"
mkdir -p "$DMG_DIR"

# 1. Build the app bundle
echo "  [1/6] Compiling Swift app..."
APP_BUNDLE="$DMG_DIR/${APP_NAME}.app"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

swiftc YabaiTomodachi.swift -o "$APP_BUNDLE/Contents/MacOS/${APP_NAME}"

# Copy icon
if [ -f "YabaiTomodachi.icns" ]; then
    cp YabaiTomodachi.icns "$APP_BUNDLE/Contents/Resources/"
elif [ -f "icons/YabaiTomodachi.icns" ]; then
    cp icons/YabaiTomodachi.icns "$APP_BUNDLE/Contents/Resources/YabaiTomodachi.icns"
fi

# Create Info.plist
cat > "$APP_BUNDLE/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDisplayName</key>
    <string>Yabai Tomodachi</string>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIconFile</key>
    <string>YabaiTomodachi</string>
    <key>CFBundleIdentifier</key>
    <string>com.halapenyoharry.yabai-tomodachi</string>
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

echo "  [2/6] Ad-hoc code signing..."
codesign -s - --force --deep "$APP_BUNDLE"

echo "  [3/6] Adding Applications symlink..."
ln -s /Applications "$DMG_DIR/Applications"

echo "  [4/6] Adding Install Yabai helper..."
cp "Install Yabai.command" "$DMG_DIR/"
chmod +x "$DMG_DIR/Install Yabai.command"

echo "  [5/6] Adding README..."
# Create a simple plain-text README for the DMG
cat > "$DMG_DIR/README.txt" << 'READMEEOF'
Yabai Tomodachi
================
Window tiling for everyone on macOS.

Yabai Tomodachi is a friendly menu bar companion that brings the power
of the yabai tiling window manager to anyone — no terminal required.


GETTING STARTED
---------------

1. Drag "Yabai-Tomodachi.app" into the "Applications" folder
   (you should see both icons in this window — just drag left to right).

2. If you don't have yabai installed yet, double-click "Install Yabai.command".
   A Terminal window will open and walk you through installing yabai via Homebrew.

3. Launch Yabai Tomodachi from your Applications folder (or Spotlight).
   It will appear as an icon in your menu bar.

4. If macOS says the app "can't be opened" or "cannot be verified":
   This is normal — the app is not notarized by Apple (yet).

   The easiest fix is to open Terminal and run:
     xattr -cr /Applications/Yabai-Tomodachi.app

   Then open the app again. It will launch normally from now on.

   Alternatively: System Settings > Privacy & Security > scroll down > "Open Anyway".

5. Grant Accessibility permissions when prompted.
   yabai needs this to manage your windows.
   The app's "Permissions Helper" (under More) can guide you.


WHAT YOU CAN DO
---------------

- Switch between Tiling and Floating layouts with one click
- Toggle individual windows in and out of tiling
- Adjust padding and gaps to get your spacing just right
- Split windows, balance layouts, rotate and mirror arrangements
- Pop open the Controls panel for quick padding/gaps tweaking


AI INTEGRATION (Optional)
-------------------------

Yabai Tomodachi includes an MCP server that lets Claude control your
windows through natural language. See the project README on GitHub
for setup instructions:

  https://github.com/halapenyoharry/yabai-tomodachi


REQUIREMENTS
------------

- macOS 12.0 (Monterey) or later
- yabai window manager (installed via Homebrew)


ABOUT
-----

Tomodachi means "friend" in Japanese. This project exists to make
the incredible power of koekeishiya's yabai accessible to everyone.

yabai is a masterpiece of macOS engineering. If you find it useful,
consider supporting the project: https://github.com/koekeishiya/yabai

License: MIT
READMEEOF

echo "  [6/6] Creating DMG..."
hdiutil create \
    -volname "${APP_NAME}" \
    -srcfolder "$DMG_DIR" \
    -ov \
    -format UDZO \
    "${DMG_NAME}.dmg"

# Clean up staging
rm -rf "$DMG_DIR"

echo ""
echo "  ================================================"
echo "  ${DMG_NAME}.dmg built successfully!"
echo "  Size: $(du -h "${DMG_NAME}.dmg" | cut -f1)"
echo "  ================================================"
echo ""
echo "  To test: open ${DMG_NAME}.dmg"
echo ""
