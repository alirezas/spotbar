# SpotBar

A lightweight macOS menubar app that displays the currently playing song as **Artist - Title**.

## Features

- Shows currently playing music from **any source** — Spotify, YouTube, SoundCloud, Apple Music, and more
- Play/pause toggle button directly in the menubar
- Real-time updates with marquee scrolling for long titles
- Uses the macOS system media session (same as Control Center) via [MediaRemote adapter](https://github.com/ungive/mediaremote-adapter)
- Hides from menubar when no music is playing
- No dock icon — runs entirely in the menubar

## Requirements

- macOS 13.0+
- Swift 5.9+
- CMake (for building the MediaRemote adapter)

## Building

```bash
make build   # Build app bundle (single arch)
make run     # Build and launch (kills previous instance)
```

Or build a universal binary (arm64 + x86_64):

```bash
make build-universal
```

The first build will automatically clone and compile the [MediaRemote adapter](https://github.com/ungive/mediaremote-adapter) framework.

## Usage

1. Build and run with `make run`
2. The app appears in your menubar showing the currently playing song
3. Click the play/pause icon to toggle playback
4. Right-click the menubar item to quit

### If macOS says "SpotBar.app is damaged"

Clear the quarantine bit:

```bash
xattr -cr SpotBar.app
open SpotBar.app
```

## How It Works

SpotBar reads now-playing information from the macOS media session — the same system that powers the Control Center widget. This means it works with any app that publishes media metadata, without needing AppleScript automation or browser permissions.

Playback control (play/pause, next, previous) is sent through the same system-level channel.

## Development

See [WORKFLOW.md](WORKFLOW.md) for the full development, versioning, and release workflow.

Quick release:

1. Update `CHANGELOG.md` with new version and changes
2. Run `make release VERSION=X.Y.Z`
