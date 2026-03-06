# SpotBar

A lightweight macOS menubar app that displays the currently playing song as **Artist - Title**.

## Features

- Shows currently playing music from Spotify, YouTube, YouTube Music, and SoundCloud
- Real-time updates with marquee scrolling for long titles
- Uses AppleScript for Spotify and Chrome tab detection for browser sources
- Hides from menubar when no music is playing
- No dock icon — runs entirely in the menubar

## Requirements

- macOS 13.0+
- Swift 5.9+

## Building

```bash
make build   # Build app bundle (single arch)
make run     # Build and launch (kills previous instance)
```

Or build a universal binary (arm64 + x86_64):

```bash
make build-universal
```

## Usage

1. Build and run with `make run`
2. The app appears in your menubar showing the currently playing song
3. Right-click the menubar item for options (Quit)

### If macOS says "SpotBar.app is damaged"

Clear the quarantine bit:

```bash
xattr -cr SpotBar.app
open SpotBar.app
```

## Permissions

The app needs automation permissions for AppleScript access:

**System Settings -> Privacy & Security -> Automation -> Allow SpotBar to control Spotify / Google Chrome**

## Development

See [WORKFLOW.md](WORKFLOW.md) for the full development, versioning, and release workflow.

Quick release:

1. Update `CHANGELOG.md` with new version and changes
2. Run `./Scripts/release.sh X.Y.Z`
