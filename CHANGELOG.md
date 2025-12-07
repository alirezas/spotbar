# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
