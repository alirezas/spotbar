# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.4.3] - 2026-04-18

### Fixed
- Settings window now renders correctly. Previously the hosted SwiftUI view was laid out before the window's style mask was applied, leaving the window blank.

## [0.4.2] - 2026-04-18

### Fixed
- Homebrew cask sha256 now matches the GitHub release asset. Release build and tap update have been moved into GitHub Actions so the uploaded zip and the cask checksum always come from the same build.

## [0.4.1] - 2026-04-17

### Fixed
- Left-clicking the track title no longer toggles playback; only the play/pause icon controls playback

## [0.4.0] - 2026-04-17

### Added
- Settings window accessible from the right-click menu
- "Launch at login" toggle (uses SMAppService)
- App info (name, version, icon) and Quit button in settings

## [0.3.0] - 2026-03-06

### Changed
- Replaced AppleScript + Chrome JavaScript injection with [MediaRemote adapter](https://github.com/ungive/mediaremote-adapter)
- Music detection now uses the macOS system media session (same as Control Center)
- Works with **any** media source — Spotify, YouTube, SoundCloud, Apple Music, VLC, and more
- Real-time streaming updates instead of 0.5s polling
- No longer requires "Allow JavaScript from Apple Events" in Chrome
- No longer requires Automation permissions for Spotify or Chrome

### Added
- Play/pause toggle button in the menubar (left of track title)
- Next/previous track control support (via MediaRemote commands)
- Auto-restart of media adapter on unexpected exit

### Removed
- AppleScript-based music detection
- Chrome tab scanning and JavaScript injection
- `MusicSource` enum (source routing now handled by the OS)

## [0.2.0] - 2026-03-06

### Changed
- Rewritten music detection to support Spotify, YouTube, YouTube Music, and SoundCloud only
- SoundCloud and YouTube now detected via Chrome tab URL instead of JavaScript injection
- Replaced deprecated `statusItem.view` API with `statusItem.button` subview
- Build system restructured: Makefile, centralized versioning (`version.env`), universal binary support
- Info.plist now generated at build time with ad-hoc code signing
- Scripts moved to `Scripts/` directory

### Added
- GitHub Actions CI for build validation on push/PR
- GitHub Actions release workflow triggered by version tags
- `make run` dev loop (kill, build, launch, verify)
- Universal binary support (arm64 + x86_64)

### Removed
- `MPNowPlayingInfoCenter` fallback (unreliable for reading other apps' now-playing info)
- Chrome JavaScript injection requirement for browser detection

## [0.1.0] - 2025-12-15

### Fixed
- Chrome video playback detection now correctly hides title when video is paused
- Fixed AppleScript syntax for executing JavaScript in Chrome tabs

### Changed
- Improved video/audio detection logic to distinguish between paused media and no media

## [0.0.3] - 2025-12-07

### Added
- Menubar item now has a context menu (right/ctrl click) with a Quit action.

### Changed
- Status item collapses to zero width when nothing is playing, keeping the bar tidy.

## [0.0.2] - 2025-12-06

### Changed
- Menubar item now fixed at 80px width to keep layout stable.
- Replaced truncation with marquee scrolling for overflowing track titles.

## [0.0.1] - 2025-12-05

### Added
- Initial release
- Menubar app that displays currently playing music
- Real-time updates of song information
- Support for Spotify, Apple Music, and other music apps
- Automatic truncation of long song names
- No dock icon (runs in menubar only)
