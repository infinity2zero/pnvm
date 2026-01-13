#!/bin/bash
# ============================================================
# Package pnvm for GitHub releases
# Creates platform-specific zip files
# ============================================================

set -euo pipefail

VERSION="${1:-v2.0.0}"
RELEASE_DIR="release"
TEMP_DIR="release-temp"

# Clean up previous releases
rm -rf "$RELEASE_DIR" "$TEMP_DIR"
mkdir -p "$RELEASE_DIR"

echo "Packaging pnvm $VERSION for GitHub release..."
echo ""

# Create universal package (all platforms)
echo "Creating universal package..."
mkdir -p "$TEMP_DIR/pnvm-$VERSION"
cp pnvm pnvm.cmd README.md LICENSE "$TEMP_DIR/pnvm-$VERSION/"
chmod +x "$TEMP_DIR/pnvm-$VERSION/pnvm"
cd "$TEMP_DIR"
zip -r "../$RELEASE_DIR/pnvm-$VERSION-universal.zip" "pnvm-$VERSION" > /dev/null
cd ..
rm -rf "$TEMP_DIR"
echo "✓ Created: pnvm-$VERSION-universal.zip"

# Create Unix-only package
echo "Creating Unix package (macOS/Linux)..."
mkdir -p "$TEMP_DIR/pnvm-$VERSION"
cp pnvm README.md LICENSE "$TEMP_DIR/pnvm-$VERSION/"
chmod +x "$TEMP_DIR/pnvm-$VERSION/pnvm"
cd "$TEMP_DIR"
zip -r "../$RELEASE_DIR/pnvm-$VERSION-unix.zip" "pnvm-$VERSION" > /dev/null
cd ..
rm -rf "$TEMP_DIR"
echo "✓ Created: pnvm-$VERSION-unix.zip"

# Create Windows-only package
echo "Creating Windows package..."
mkdir -p "$TEMP_DIR/pnvm-$VERSION"
cp pnvm.cmd README.md LICENSE "$TEMP_DIR/pnvm-$VERSION/"
cd "$TEMP_DIR"
zip -r "../$RELEASE_DIR/pnvm-$VERSION-windows.zip" "pnvm-$VERSION" > /dev/null
cd ..
rm -rf "$TEMP_DIR"
echo "✓ Created: pnvm-$VERSION-windows.zip"

echo ""
echo "Packaging complete! Files created in '$RELEASE_DIR/':"
ls -lh "$RELEASE_DIR"/*.zip
echo ""
echo "Next steps:"
echo "1. Create a GitHub release with tag: $VERSION"
echo "2. Upload these zip files as release assets"
echo "3. GitHub will automatically track download counts"
echo ""
