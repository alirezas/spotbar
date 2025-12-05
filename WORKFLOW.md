# Build, Deploy, Versioning, and Release Workflow

This document describes the complete workflow for building, versioning, and releasing SpotBar.

## Versioning

SpotBar follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html) (SemVer):

- **MAJOR** version for incompatible API changes
- **MINOR** version for backwards-compatible functionality additions
- **PATCH** version for backwards-compatible bug fixes

### Version Format

Versions are formatted as `MAJOR.MINOR.PATCH` (e.g., `0.0.1`, `1.2.3`).

### Version Tracking

- Version information is maintained in `CHANGELOG.md`
- Git tags follow the format `vMAJOR.MINOR.PATCH` (e.g., `v0.0.1`)
- Each release corresponds to a git tag and GitHub release

## Build Process

### Prerequisites

- macOS 13.0 or later
- Swift 5.9 or later
- Git
- GitHub CLI (`gh`) for releases

### Building the App Bundle

The recommended way to build a distributable app bundle:

```bash
./create_app.sh
```

This script:
1. Builds the Swift package in release mode (`swift build -c release`)
2. Creates the macOS app bundle structure (`SpotBar.app/Contents/`)
3. Copies the compiled executable to `Contents/MacOS/SpotBar`
4. Copies `Info.plist` to `Contents/Info.plist`
5. Copies `icon.icns` to `Contents/Resources/icon.icns`
6. Makes the executable executable

The output is `SpotBar.app`, ready for distribution.

### Alternative Build Methods

**Swift Package Manager (executable only):**
```bash
swift build -c release
```
Output: `.build/release/SpotBar`

**Xcode:**
```bash
open Package.swift
```
Then build using Xcode (⌘B)

## Release Workflow

### Step 1: Update CHANGELOG

Before creating a release, update `CHANGELOG.md` with the new version and changes:

```markdown
## [X.Y.Z] - YYYY-MM-DD

### Added
- New feature description

### Changed
- Change description

### Fixed
- Bug fix description
```

Follow the [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) format.

### Step 2: Commit Changes

Commit all changes including the updated CHANGELOG:

```bash
git add .
git commit -m "Prepare release vX.Y.Z"
git push
```

### Step 3: Build the App

Build the app bundle for release:

```bash
./create_app.sh
```

This creates `SpotBar.app` ready for distribution.

### Step 4: Create Git Tag

Create an annotated git tag for the version:

```bash
git tag -a vX.Y.Z -m "Release vX.Y.Z: Description of changes"
git push origin vX.Y.Z
```

### Step 5: Create GitHub Release

Create the GitHub release with release notes from CHANGELOG:

```bash
gh release create vX.Y.Z \
  --title "vX.Y.Z - Release Title" \
  --notes "$(cat <<EOF
## Added
- Feature 1
- Feature 2

## Changed
- Change 1

## Fixed
- Fix 1
EOF
)"
```

### Step 6: Attach App Bundle

Package and attach the app bundle to the release:

```bash
zip -r SpotBar.app.zip SpotBar.app
gh release upload vX.Y.Z SpotBar.app.zip
rm SpotBar.app.zip  # Clean up local zip
```

### Complete Release Script

For convenience, here's a complete release workflow:

```bash
#!/bin/bash
# release.sh - Complete release workflow

VERSION=$1
if [ -z "$VERSION" ]; then
    echo "Usage: ./release.sh X.Y.Z"
    exit 1
fi

# Build app
echo "Building SpotBar..."
./create_app.sh

# Create tag
echo "Creating tag v$VERSION..."
git tag -a "v$VERSION" -m "Release v$VERSION"

# Push tag
echo "Pushing tag..."
git push origin "v$VERSION"

# Create zip
echo "Creating archive..."
zip -r SpotBar.app.zip SpotBar.app

# Create release (you'll need to manually add release notes)
echo "Creating GitHub release..."
gh release create "v$VERSION" \
  --title "v$VERSION" \
  --notes "See CHANGELOG.md for details" \
  SpotBar.app.zip

# Cleanup
rm SpotBar.app.zip
echo "Release v$VERSION created!"
```

## Deployment

### Local Testing

Before releasing, test the app bundle locally:

```bash
./create_app.sh
open SpotBar.app
```

Verify:
- App appears in menubar
- Displays currently playing music correctly
- Updates in real-time
- Handles edge cases (no music playing, long song names, etc.)

### Distribution

The release process automatically:
1. Creates a GitHub release
2. Attaches `SpotBar.app.zip` as a downloadable asset
3. Users can download, unzip, and run the app

### Post-Release

After a successful release:
1. Verify the release appears on GitHub
2. Test downloading and running the app from the release
3. Update any documentation if needed
4. Announce the release (if applicable)

## Workflow Summary

```
1. Update CHANGELOG.md
   ↓
2. Commit and push changes
   ↓
3. Build app bundle (./create_app.sh)
   ↓
4. Create git tag (vX.Y.Z)
   ↓
5. Push tag to GitHub
   ↓
6. Create GitHub release with notes
   ↓
7. Attach SpotBar.app.zip to release
   ↓
8. Verify release on GitHub
```

## Troubleshooting

### Build Issues

- **Swift version mismatch**: Ensure Swift 5.9+ is installed (`swift --version`)
- **Missing dependencies**: Run `swift package resolve`
- **Permission errors**: Ensure scripts are executable (`chmod +x create_app.sh`)

### Release Issues

- **Tag already exists**: Delete local and remote tag, then recreate
  ```bash
  git tag -d vX.Y.Z
  git push origin :refs/tags/vX.Y.Z
  ```
- **GitHub CLI not authenticated**: Run `gh auth login`
- **Release creation fails**: Check GitHub permissions and network connection

### App Bundle Issues

- **App won't run**: Check executable permissions (`chmod +x SpotBar.app/Contents/MacOS/SpotBar`)
- **Missing icon**: Ensure `icon.icns` exists and is copied to Resources
- **Info.plist errors**: Verify `Info.plist` is valid XML
