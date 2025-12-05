#!/bin/bash

# Script to create icon.icns from PNG files in assets/

echo "Creating icon.icns from PNG assets..."

# Clean up any existing iconset
rm -rf icon.iconset
mkdir -p icon.iconset

# Find the PNG files
ASSETS_DIR="assets"
ICONSET_DIR="icon.iconset"

# Map the PNG files to iconset structure
cp "$ASSETS_DIR/MacOS-16.png" "$ICONSET_DIR/icon_16x16.png"
cp "$ASSETS_DIR/MacOS-32.png" "$ICONSET_DIR/icon_16x16@2x.png"
cp "$ASSETS_DIR/MacOS-32.png" "$ICONSET_DIR/icon_32x32.png"
cp "$ASSETS_DIR/MacOS-64.png" "$ICONSET_DIR/icon_32x32@2x.png"
cp "$ASSETS_DIR/MacOS-128.png" "$ICONSET_DIR/icon_128x128.png"
cp "$ASSETS_DIR/MacOS-256.png" "$ICONSET_DIR/icon_128x128@2x.png"
cp "$ASSETS_DIR/MacOS-256.png" "$ICONSET_DIR/icon_256x256.png"
cp "$ASSETS_DIR/MacOS-512.png" "$ICONSET_DIR/icon_256x256@2x.png"
cp "$ASSETS_DIR/MacOS-512.png" "$ICONSET_DIR/icon_512x512.png"
cp "$ASSETS_DIR/MacOS-1024.png" "$ICONSET_DIR/icon_512x512@2x.png"

# Convert iconset to icns
echo "Converting iconset to icns..."
iconutil -c icns "$ICONSET_DIR" -o icon.icns

if [ $? -eq 0 ]; then
    echo "Successfully created icon.icns"
    rm -rf "$ICONSET_DIR"
else
    echo "Error: Failed to create icon.icns"
    exit 1
fi
