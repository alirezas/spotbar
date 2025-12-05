#!/bin/bash

# release.sh - Automated release workflow for SpotBar
# Usage: ./release.sh X.Y.Z

set -e

VERSION=$1
if [ -z "$VERSION" ]; then
    echo "Usage: ./release.sh X.Y.Z"
    echo "Example: ./release.sh 0.0.2"
    exit 1
fi

# Validate version format (basic check)
if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Error: Version must be in format X.Y.Z (e.g., 0.0.2)"
    exit 1
fi

TAG="v$VERSION"
ZIP_FILE="SpotBar.app.zip"

echo "🚀 Starting release workflow for $TAG"
echo ""

# Check if tag already exists
if git rev-parse "$TAG" >/dev/null 2>&1; then
    echo "❌ Error: Tag $TAG already exists"
    echo "   Delete it with: git tag -d $TAG && git push origin :refs/tags/$TAG"
    exit 1
fi

# Check if CHANGELOG has the version
if ! grep -q "## \[$VERSION\]" CHANGELOG.md; then
    echo "⚠️  Warning: CHANGELOG.md doesn't contain version $VERSION"
    echo "   Please update CHANGELOG.md before releasing"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo "⚠️  Warning: You have uncommitted changes"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Build app
echo "📦 Building SpotBar..."
./create_app.sh

if [ ! -d "SpotBar.app" ]; then
    echo "❌ Error: SpotBar.app was not created"
    exit 1
fi

# Create zip
echo "📦 Creating archive..."
rm -f "$ZIP_FILE"
zip -r "$ZIP_FILE" SpotBar.app > /dev/null

# Create git tag
echo "🏷️  Creating git tag $TAG..."
git tag -a "$TAG" -m "Release $TAG"

# Push tag
echo "📤 Pushing tag to GitHub..."
git push origin "$TAG"

# Extract release notes from CHANGELOG
echo "📝 Extracting release notes from CHANGELOG..."
RELEASE_NOTES=$(awk "/^## \[$VERSION\]/,/^## \[/" CHANGELOG.md | sed '$d' | sed '1d')

if [ -z "$RELEASE_NOTES" ]; then
    RELEASE_NOTES="See CHANGELOG.md for details"
fi

# Create GitHub release
echo "🚀 Creating GitHub release..."
gh release create "$TAG" \
    --title "$TAG" \
    --notes "$RELEASE_NOTES" \
    "$ZIP_FILE"

# Cleanup
echo "🧹 Cleaning up..."
rm -f "$ZIP_FILE"

echo ""
echo "✅ Release $TAG created successfully!"
echo "   View at: https://github.com/alirezas/spotbar/releases/tag/$TAG"
