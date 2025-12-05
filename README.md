# SpotBar

A macOS menubar app that displays the currently playing song in "artist - song" format.

## Features

- Displays currently playing music from any app (Spotify, Apple Music, etc.)
- Updates in real-time
- No dock icon (runs in menubar only)
- Automatically truncates long song names

## Building

### Create App Bundle (Recommended)

The easiest way to build a proper macOS app bundle:

```bash
./create_app.sh
```

This will create `SpotBar.app` which you can double-click to run or move to your Applications folder.

### Using Swift Package Manager

```bash
swift build -c release
```

The executable will be in `.build/release/SpotBar`

### Using Xcode

1. Open the project in Xcode:
   ```bash
   open Package.swift
   ```

2. Select the `SpotBar` scheme and build (⌘B)

3. Run the app (⌘R)

## Usage

1. Build and run the app
2. The app will appear in your menubar showing the currently playing song
3. If no music is playing, it will display "No music playing"

## Permissions

The app uses the MediaPlayer framework to access system-wide music information. For Spotify, it uses AppleScript which may require automation permissions:
- System Settings → Privacy & Security → Automation
- Allow SpotBar to control Spotify

## Requirements

- macOS 13.0 or later
- Swift 5.9 or later

## Development Workflow

For detailed information on building, versioning, and releasing SpotBar, see [WORKFLOW.md](WORKFLOW.md).

Quick release workflow:
1. Update `CHANGELOG.md` with new version and changes
2. Build: `./create_app.sh`
3. Tag: `git tag -a vX.Y.Z -m "Release vX.Y.Z"`
4. Push tag: `git push origin vX.Y.Z`
5. Create release: `gh release create vX.Y.Z --title "vX.Y.Z" --notes "..." SpotBar.app.zip`
