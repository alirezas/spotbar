#!/bin/bash

# Build the app
echo "Building SpotBar..."
swift build -c release

# Create app bundle structure
APP_NAME="SpotBar.app"
APP_PATH="$APP_NAME/Contents"
EXECUTABLE_PATH="$APP_PATH/MacOS"
RESOURCES_PATH="$APP_PATH/Resources"

echo "Creating app bundle structure..."
rm -rf "$APP_NAME"
mkdir -p "$EXECUTABLE_PATH"
mkdir -p "$RESOURCES_PATH"

# Copy executable
echo "Copying executable..."
cp .build/release/SpotBar "$EXECUTABLE_PATH/SpotBar"

# Copy Info.plist
echo "Copying Info.plist..."
cp Info.plist "$APP_PATH/Info.plist"

# Make executable
chmod +x "$EXECUTABLE_PATH/SpotBar"

echo "App bundle created: $APP_NAME"
echo "You can now run: open $APP_NAME"
