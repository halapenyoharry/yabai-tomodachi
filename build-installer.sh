#!/bin/bash

# Build script for Yabai-Tomodachi installer

VERSION="1.0.0"
PRODUCT_NAME="YabaiTomodachi"

echo "Building Yabai-Tomodachi installer v$VERSION..."

# Clean previous builds
rm -rf installer/Payload/Applications/*
rm -f *.pkg

# Compile the Swift app
echo "Compiling YabaiRestarter..."
swiftc YabaiRestarter.swift -o installer/Payload/Applications/YabaiRestarter

# Build the package
echo "Building package..."
pkgbuild --root installer/Payload \
         --scripts installer/Scripts \
         --identifier com.yabai.tomodachi \
         --version "$VERSION" \
         --install-location / \
         "${PRODUCT_NAME}-${VERSION}.pkg"

echo "Package built: ${PRODUCT_NAME}-${VERSION}.pkg"
echo ""
echo "To install:"
echo "  sudo installer -pkg ${PRODUCT_NAME}-${VERSION}.pkg -target /"
echo ""
echo "Or double-click the .pkg file to use the GUI installer"