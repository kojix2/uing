#!/bin/bash
set -e

# Load configuration from .env
set -a
source .env
set +a

DIST_DIR="dist"

echo "Building $APP_NAME v$VERSION..."
shards build --release

rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"

# Create .app bundle first
./build-mac.sh

# Create .pkg package
TEMP_DIR=$(mktemp -d)
mkdir -p "$TEMP_DIR/Applications"

if [ -d "$DIST_DIR/$APP_NAME_CAPITALIZED.app" ]; then
    cp -R "$DIST_DIR/$APP_NAME_CAPITALIZED.app" "$TEMP_DIR/Applications/"
else
    echo "Error: .app bundle not found"
    exit 1
fi

fpm -s dir -t osxpkg \
    --name "$APP_NAME" \
    --version "$VERSION" \
    --description "$DESCRIPTION" \
    --maintainer "$MAINTAINER" \
    --license "$LICENSE" \
    --url "$URL" \
    --package "$DIST_DIR/${APP_NAME}-${VERSION}.pkg" \
    -C "$TEMP_DIR" \
    .

rm -rf "$TEMP_DIR"

echo "Created: $DIST_DIR/${APP_NAME}.dmg"
echo "Created: $DIST_DIR/${APP_NAME}-${VERSION}.pkg"
