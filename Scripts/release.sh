#!/usr/bin/env bash
# release.sh - Automated release workflow for SpotBar
# Usage: ./Scripts/release.sh X.Y.Z
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT"

VERSION=${1:-}
if [[ -z "$VERSION" ]]; then
  echo "Usage: ./Scripts/release.sh X.Y.Z"
  echo "Example: ./Scripts/release.sh 0.2.0"
  exit 1
fi

if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Error: Version must be in format X.Y.Z (e.g., 0.2.0)"
  exit 1
fi

TAG="v$VERSION"

echo "Starting release workflow for $TAG"
echo ""

# Check if tag already exists
if git rev-parse "$TAG" >/dev/null 2>&1; then
  echo "Error: Tag $TAG already exists"
  echo "  Delete it with: git tag -d $TAG && git push origin :refs/tags/$TAG"
  exit 1
fi

# Check if CHANGELOG has the version
if ! grep -q "## \[$VERSION\]" CHANGELOG.md; then
  echo "Warning: CHANGELOG.md doesn't contain version $VERSION"
  echo "  Please update CHANGELOG.md before releasing"
  read -p "Continue anyway? (y/N) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
  fi
fi

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
  echo "Warning: You have uncommitted changes"
  read -p "Continue anyway? (y/N) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
  fi
fi

# Update version.env
source "$ROOT/version.env"
NEW_BUILD=$(( BUILD_NUMBER + 1 ))
sed -i '' "s/^MARKETING_VERSION=.*/MARKETING_VERSION=$VERSION/" version.env
sed -i '' "s/^BUILD_NUMBER=.*/BUILD_NUMBER=$NEW_BUILD/" version.env
echo "Updated version.env: $VERSION (build $NEW_BUILD)"

# Commit version bump
echo "Committing version bump..."
git add version.env
git commit -m "Release v$VERSION"

# Create git tag
echo "Creating git tag $TAG..."
git tag -a "$TAG" -m "Release $TAG"

# Push commit and tag — GHA release.yml handles build, GitHub release, and tap update
echo "Pushing to GitHub..."
git push
git push origin "$TAG"

echo ""
echo "Tag $TAG pushed. GitHub Actions will build, publish the release, and update the Homebrew tap."
echo "  Watch: https://github.com/alirezas/spotbar/actions"
