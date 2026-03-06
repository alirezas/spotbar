#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT"

echo "Creating icon.icns from PNG assets..."

rm -rf icon.iconset
mkdir -p icon.iconset

ASSETS_DIR="assets"

cp "$ASSETS_DIR/MacOS-16.png" "icon.iconset/icon_16x16.png"
cp "$ASSETS_DIR/MacOS-32.png" "icon.iconset/icon_16x16@2x.png"
cp "$ASSETS_DIR/MacOS-32.png" "icon.iconset/icon_32x32.png"
cp "$ASSETS_DIR/MacOS-64.png" "icon.iconset/icon_32x32@2x.png"
cp "$ASSETS_DIR/MacOS-128.png" "icon.iconset/icon_128x128.png"
cp "$ASSETS_DIR/MacOS-256.png" "icon.iconset/icon_128x128@2x.png"
cp "$ASSETS_DIR/MacOS-256.png" "icon.iconset/icon_256x256.png"
cp "$ASSETS_DIR/MacOS-512.png" "icon.iconset/icon_256x256@2x.png"
cp "$ASSETS_DIR/MacOS-512.png" "icon.iconset/icon_512x512.png"
cp "$ASSETS_DIR/MacOS-1024.png" "icon.iconset/icon_512x512@2x.png"

echo "Converting iconset to icns..."
iconutil -c icns "icon.iconset" -o icon.icns

rm -rf icon.iconset
echo "Successfully created icon.icns"
