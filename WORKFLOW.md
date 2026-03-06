# Development Workflow

## Version Management

Version is tracked in a single file: `version.env`

```
MARKETING_VERSION=0.1.0
BUILD_NUMBER=5
```

- `MARKETING_VERSION` — semver displayed to users (CFBundleShortVersionString)
- `BUILD_NUMBER` — incremental build number (CFBundleVersion)
- `Info.plist` is generated at build time from these values — no manual plist editing

```bash
make version      # Print current version
make bump-build   # Increment build number
```

## Development

### Quick Build & Run

```bash
make run
```

This kills any running SpotBar instance, builds a release binary, creates the `.app` bundle, launches it, and verifies the process started.

### Build Only

```bash
make build             # Single arch (host architecture)
make build-universal   # Universal binary (arm64 + x86_64)
```

### Other Commands

```bash
make clean   # Remove .build/ and SpotBar.app
make icon    # Regenerate icon.icns from assets/ PNGs
```

## Scripts

All scripts live in `Scripts/`:

| Script | Purpose |
|--------|---------|
| `package_app.sh` | Build binary, create .app bundle, generate Info.plist, code sign |
| `compile_and_run.sh` | Dev loop: kill, build, launch, verify |
| `create_icon.sh` | Generate icon.icns from PNG assets |
| `release.sh` | Full release workflow |

### Environment Variables

`package_app.sh` accepts these environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `APP_NAME` | SpotBar | App and binary name |
| `BUNDLE_ID` | com.dot.spotbar | Bundle identifier |
| `ARCHES` | host arch | Space-separated architectures (e.g., `arm64 x86_64`) |
| `SIGNING_MODE` | adhoc | `adhoc` for dev, or set `APP_IDENTITY` for Developer ID |
| `APP_IDENTITY` | (empty) | Code signing identity for release builds |

## Releasing

### Prerequisites

- [GitHub CLI](https://cli.github.com/) (`gh`) installed and authenticated
- Clean working tree (no uncommitted changes)
- Updated `CHANGELOG.md` with the new version entry

### Release Process

```bash
# 1. Update CHANGELOG.md with new version and changes
# 2. Commit: git add CHANGELOG.md && git commit -m "Update changelog for 0.2.0"
# 3. Release:
make release
# or directly:
./Scripts/release.sh 0.2.0
```

The release script:
1. Validates semver format
2. Checks CHANGELOG.md contains the version
3. Checks for clean working tree
4. Updates `version.env` with new version + bumps build number
5. Builds a universal binary (arm64 + x86_64)
6. Creates `SpotBar-X.Y.Z.zip`
7. Commits the version.env change
8. Creates annotated git tag `vX.Y.Z`
9. Pushes commit and tag
10. Creates GitHub release with notes extracted from CHANGELOG

## CI/CD

### Build Validation (`.github/workflows/ci.yml`)

Runs on every push to `main` and on pull requests:
- Compiles the Swift package
- Builds the app bundle via `package_app.sh`
- Verifies bundle structure and code signature

### Tag-Triggered Release (`.github/workflows/release.yml`)

When a `v*` tag is pushed:
- Builds a universal binary
- Creates a versioned zip
- Creates a GitHub release with notes from CHANGELOG

## Code Signing

**Development:** Ad-hoc signing by default (`codesign -s "-"`). No certificates needed.

**Release with Developer ID:** Set the `APP_IDENTITY` environment variable:

```bash
APP_IDENTITY="Developer ID Application: Your Name (TEAMID)" make build
```

**Notarization:** Not yet configured. When ready, add a `Scripts/sign-and-notarize.sh` using `xcrun notarytool`.

## Project Structure

```
SpotBar/
  Sources/SpotBar/        # Swift source files
  Scripts/                # Build, run, release scripts
  assets/                 # Icon PNGs (16px - 1024px)
  .github/workflows/     # CI/CD
  version.env            # Version single source of truth
  Makefile               # Unified commands
  CHANGELOG.md           # Release history
  WORKFLOW.md            # This file
  Package.swift          # SPM package definition
  icon.icns              # Compiled app icon
```
