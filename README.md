# SpotBar

A minimal macOS menu bar app that displays the currently playing Spotify song with a marquee scrolling effect.

## Features

- Shows current Spotify track (artist - title) in the menu bar
- Marquee scrolling for long text
- Auto-hides when Spotify is paused or not running
- Compatible with menu bar managers like Ice
- Right-click menu for Restart and Quit

## Requirements

- macOS 10.15+
- Spotify app installed

## Build

```bash
swift build
```

## Install

```bash
cp .build/debug/SpotBar SpotBar.app/Contents/MacOS/SpotBar
open SpotBar.app
```

## Run (Development)

```bash
swift run
```

## Permissions

Grant automation permissions for SpotBar to control Spotify:
System Preferences > Security & Privacy > Privacy > Automation

## License

MIT
