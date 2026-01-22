#!/bin/bash

# Build Desktop Extension (.dxt) for yabai-tomodachi
echo "Building yabai-tomodachi Desktop Extension (.dxt)..."

# Clean previous build
rm -rf temp/dxt-build
rm -f yabai-tomodachi.dxt

# Create temporary build directory
mkdir -p temp/dxt-build

# Build TypeScript
echo "Building TypeScript..."
npm run build

# Copy required files to build directory
echo "Copying files for .dxt package..."
cp manifest.json temp/dxt-build/
cp package.json temp/dxt-build/
cp -r dist temp/dxt-build/
cp -r node_modules temp/dxt-build/

# Copy icon if it exists
if [ -f "icons/YabaiTomodachi.png" ]; then
    cp icons/YabaiTomodachi.png temp/dxt-build/icon.png
else
    echo "Warning: No icon found, creating placeholder"
    # Create a simple placeholder if no icon exists
    echo "📱" > temp/dxt-build/icon.png
fi

# Create .dxt file (ZIP archive)
echo "Creating .dxt package..."
cd temp/dxt-build
zip -r ../../yabai-tomodachi.dxt .
cd ../..

# Cleanup
rm -rf temp/dxt-build

echo "✅ Desktop extension built: yabai-tomodachi.dxt"
echo "📁 Size: $(du -h yabai-tomodachi.dxt | cut -f1)"
echo ""
echo "To install:"
echo "  Double-click yabai-tomodachi.dxt"
echo "  Or use Claude Desktop's extension manager"