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

# Create temporary directory structure
TEMP_DIR=$(mktemp -d)
mkdir -p "$TEMP_DIR/usr/bin"
mkdir -p "$TEMP_DIR/usr/share/applications"
mkdir -p "$TEMP_DIR/usr/share/icons/hicolor/256x256/apps"

# Copy binary
cp "bin/$APP_NAME" "$TEMP_DIR/usr/bin/"

# Generate desktop entry
cat > "$TEMP_DIR/usr/share/applications/$APP_NAME.desktop" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=MD5 Checker
Comment=$DESCRIPTION
Exec=$APP_NAME
Icon=$APP_NAME
Terminal=false
Categories=Utility;
StartupNotify=true
EOF

# Copy icon if it exists
if [ -f "resources/app_icon.png" ]; then
    cp "resources/app_icon.png" "$TEMP_DIR/usr/share/icons/hicolor/256x256/apps/$APP_NAME.png"
fi

# Create deb package
fpm -s dir -t deb \
    --name "$APP_NAME" \
    --version "$VERSION" \
    --description "$DESCRIPTION" \
    --maintainer "$MAINTAINER" \
    --license "$LICENSE" \
    --url "$URL" \
    --deb-no-default-config-files \
    --depends "libgtk-3-0t64" \
    --depends "libglib2.0-0t64" \
    --depends "libpango-1.0-0" \
    --depends "libcairo2" \
    --depends "libssl3t64" \
    --depends "libgc1" \
    --package "$DIST_DIR/${APP_NAME}_${VERSION}_amd64.deb" \
    -C "$TEMP_DIR" \
    .

rm -rf "$TEMP_DIR"

echo "Created: $DIST_DIR/${APP_NAME}_${VERSION}_amd64.deb"
