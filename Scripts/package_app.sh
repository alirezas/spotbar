#!/usr/bin/env bash
set -euo pipefail

CONF=${1:-release}
ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT"

APP_NAME=${APP_NAME:-SpotBar}
BUNDLE_ID=${BUNDLE_ID:-com.dot.spotbar}
MACOS_MIN_VERSION=${MACOS_MIN_VERSION:-13.0}
MENU_BAR_APP=1
SIGNING_MODE=${SIGNING_MODE:-adhoc}
APP_IDENTITY=${APP_IDENTITY:-}

if [[ -f "$ROOT/version.env" ]]; then
  source "$ROOT/version.env"
else
  MARKETING_VERSION=${MARKETING_VERSION:-0.1.0}
  BUILD_NUMBER=${BUILD_NUMBER:-1}
fi

ARCH_LIST=( ${ARCHES:-} )
if [[ ${#ARCH_LIST[@]} -eq 0 ]]; then
  HOST_ARCH=$(uname -m)
  ARCH_LIST=("$HOST_ARCH")
fi

echo "Building $APP_NAME $MARKETING_VERSION ($BUILD_NUMBER) for ${ARCH_LIST[*]}..."

for ARCH in "${ARCH_LIST[@]}"; do
  swift build -c "$CONF" --arch "$ARCH"
done

APP="$ROOT/${APP_NAME}.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

# Generate Info.plist
BUILD_TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
GIT_COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")

cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key><string>${APP_NAME}</string>
    <key>CFBundleDisplayName</key><string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key><string>${BUNDLE_ID}</string>
    <key>CFBundleExecutable</key><string>${APP_NAME}</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>CFBundleShortVersionString</key><string>${MARKETING_VERSION}</string>
    <key>CFBundleVersion</key><string>${BUILD_NUMBER}</string>
    <key>LSMinimumSystemVersion</key><string>${MACOS_MIN_VERSION}</string>
    <key>LSUIElement</key><true/>
    <key>NSHighResolutionCapable</key><true/>
    <key>CFBundleIconFile</key><string>icon</string>
    <key>NSAppleEventsUsageDescription</key><string>SpotBar needs permission to read media info from Spotify and Google Chrome.</string>
    <key>BuildTimestamp</key><string>${BUILD_TIMESTAMP}</string>
    <key>GitCommit</key><string>${GIT_COMMIT}</string>
</dict>
</plist>
PLIST

# Helper: resolve build product path for a given arch
build_product_path() {
  local name="$1" arch="$2"
  echo ".build/${arch}-apple-macosx/$CONF/$name"
}

# Install binary (single or universal via lipo)
install_binary() {
  local name="$1" dest="$2"
  local binaries=()
  for arch in "${ARCH_LIST[@]}"; do
    local src
    src=$(build_product_path "$name" "$arch")
    if [[ ! -f "$src" ]]; then
      echo "ERROR: Missing ${name} build for ${arch} at ${src}" >&2
      exit 1
    fi
    binaries+=("$src")
  done
  if [[ ${#ARCH_LIST[@]} -gt 1 ]]; then
    lipo -create "${binaries[@]}" -output "$dest"
  else
    cp "${binaries[0]}" "$dest"
  fi
  chmod +x "$dest"
}

install_binary "$APP_NAME" "$APP/Contents/MacOS/$APP_NAME"

# Copy icon
if [[ -f "$ROOT/icon.icns" ]]; then
  cp "$ROOT/icon.icns" "$APP/Contents/Resources/icon.icns"
fi

# Copy SwiftPM resource bundles if any
PREFERRED_BUILD_DIR="$(dirname "$(build_product_path "$APP_NAME" "${ARCH_LIST[0]}")")"
shopt -s nullglob
SWIFTPM_BUNDLES=("${PREFERRED_BUILD_DIR}/"*.bundle)
shopt -u nullglob
for bundle in "${SWIFTPM_BUNDLES[@]+"${SWIFTPM_BUNDLES[@]}"}"; do
  cp -R "$bundle" "$APP/Contents/Resources/"
done

# Strip extended attributes
chmod -R u+w "$APP"
xattr -cr "$APP"
find "$APP" -name '._*' -delete

# Code sign
if [[ "$SIGNING_MODE" == "adhoc" || -z "$APP_IDENTITY" ]]; then
  codesign --force --sign "-" "$APP"
else
  codesign --force --timestamp --options runtime --sign "$APP_IDENTITY" "$APP"
fi

echo "Created $APP ($MARKETING_VERSION build $BUILD_NUMBER)"
