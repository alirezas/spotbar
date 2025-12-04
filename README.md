# SpotBar

A native macOS menubar app that displays the current playing song from Spotify in a pill-shaped view with scrolling text.

## Features

- Displays current Spotify song title and artist
- Pill-shaped transparent design
- Scrolling text for long titles
- Right-click menu for Restart and Quit
- Adapts to light/dark mode

## Requirements

- macOS 10.12+
- Spotify app installed and running

## Build

```bash
swift build
```

## Run

```bash
open SpotBar.app
```

Or after building:

```bash
swift run
```

## Permissions

Grant automation permissions for SpotBar to control Spotify in System Preferences > Security & Privacy > Privacy > Automation.

## License

MIT