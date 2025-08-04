# Packaging Yabai-Tomadachi

## Current Package Structure

```
YabaiTomadachi.app/
├── Contents/
│   ├── Info.plist          # App metadata
│   ├── MacOS/
│   │   └── YabaiTomadachi  # Main executable
│   └── Resources/
│       └── YabaiTomodachi.icns  # App icon
```

## Why We Don't Bundle Yabai

After analyzing yabai's update frequency (3-4 releases/year), we decided NOT to bundle yabai because:

1. **Automatic Updates** - Users get yabai updates via Homebrew
2. **Smaller Package** - Our app is <1MB vs 3MB with yabai
3. **User Choice** - Some users need specific yabai versions
4. **Simpler Maintenance** - No repackaging for each yabai update
5. **Clean Separation** - We're a companion, not a replacement

## Building a Release

### 1. Update Version
Edit `Info.plist`:
```xml
<key>CFBundleShortVersionString</key>
<string>1.0.1</string>
<key>CFBundleVersion</key>
<string>2</string>
```

### 2. Compile Fresh Binary
```bash
swiftc src/YabaiRestarter.swift -o YabaiTomadachi
cp YabaiTomadachi YabaiTomadachi.app/Contents/MacOS/
```

### 3. Sign the App (Optional)
```bash
codesign --force --deep --sign - YabaiTomadachi.app
```

### 4. Create DMG
```bash
# Create a temporary directory
mkdir -p dist/dmg
cp -R YabaiTomadachi.app dist/dmg/
ln -s /Applications dist/dmg/Applications

# Create DMG
hdiutil create -volname "Yabai Tomadachi" -srcfolder dist/dmg -ov -format UDZO YabaiTomadachi.dmg
```

### 5. Or Create ZIP
```bash
zip -r YabaiTomadachi.app.zip YabaiTomadachi.app
```

## Creating an Installer Package (.pkg)

For a more professional installation experience:

```bash
# Build the package
pkgbuild --root YabaiTomadachi.app \
         --identifier com.halapenyoharry.yabai-tomadachi \
         --version 1.0.0 \
         --install-location /Applications/YabaiTomadachi.app \
         YabaiTomadachi.pkg

# Or with a custom script
pkgbuild --root YabaiTomadachi.app \
         --identifier com.halapenyoharry.yabai-tomadachi \
         --version 1.0.0 \
         --scripts scripts \
         --install-location /Applications/YabaiTomadachi.app \
         YabaiTomadachi.pkg
```

## Release Checklist

- [ ] Update version in Info.plist
- [ ] Update version in package.json (for MCP)
- [ ] Compile fresh binary
- [ ] Test app bundle
- [ ] Create DMG or ZIP
- [ ] Test installation on clean system
- [ ] Create GitHub release
- [ ] Upload artifacts

## Future Packaging Ideas

1. **Homebrew Cask** - Easy installation via `brew install --cask yabai-tomadachi`
2. **Notarization** - Apple notarization for Gatekeeper approval
3. **Auto-updater** - Sparkle framework integration
4. **Universal Binary** - Support both Intel and Apple Silicon