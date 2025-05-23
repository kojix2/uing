#!/bin/bash
set -e

# Load configuration from .env
set -a
source .env
set +a

EXECUTABLE_PATH="bin/$APP_NAME"
APP_BUNDLE="$APP_NAME_CAPITALIZED.app"
MACOS_DIR="$APP_BUNDLE/Contents/MacOS"
RESOURCES_DIR="$APP_BUNDLE/Contents/Resources"
FRAMEWORKS_DIR="$APP_BUNDLE/Contents/Frameworks"
PLIST_PATH="$APP_BUNDLE/Contents/Info.plist"
ICON_NAME="app_icon"
ICON_PATH="resources/$ICON_NAME.icns"
DMG_NAME="${APP_NAME}.dmg"
VOL_NAME="$APP_NAME_CAPITALIZED"
STAGING_DIR="dmg_stage"
DIST_DIR="dist"

echo "Building $APP_NAME v$VERSION..."
shards install
shards build --release

rm -rf "$APP_BUNDLE" "$DMG_NAME" "$STAGING_DIR" "$DIST_DIR"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR" "$FRAMEWORKS_DIR" "$DIST_DIR"

# Create .app bundle
cp "$EXECUTABLE_PATH" "$MACOS_DIR/$APP_NAME"
chmod +x "$MACOS_DIR/$APP_NAME"

if [ -f "$ICON_PATH" ]; then
  cp "$ICON_PATH" "$RESOURCES_DIR/$ICON_NAME.icns"
fi

# Create Info.plist
cat > "$PLIST_PATH" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" \
 "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleExecutable</key>
  <string>$APP_NAME</string>
  <key>CFBundleIdentifier</key>
  <string>com.example.$APP_NAME</string>
  <key>CFBundleName</key>
  <string>$APP_NAME</string>
  <key>CFBundleVersion</key>
  <string>$VERSION</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleIconFile</key>
  <string>$ICON_NAME</string>
</dict>
</plist>
EOF

# Bundle Homebrew libraries
otool -L "$MACOS_DIR/$APP_NAME" \
| awk '{print $1}' \
| grep "^/opt/homebrew" \
| while read -r lib; do
    base=$(basename "$lib")
    cp "$lib" "$FRAMEWORKS_DIR/$base"
    install_name_tool -change "$lib" "@executable_path/../Frameworks/$base" "$MACOS_DIR/$APP_NAME"
done

# Create DMG
mkdir -p "$STAGING_DIR"
cp -R "$APP_BUNDLE" "$STAGING_DIR/"
ln -s /Applications "$STAGING_DIR/Applications"

hdiutil create "$DMG_NAME" \
  -volname "$VOL_NAME" \
  -srcfolder "$STAGING_DIR" \
  -fs HFS+ \
  -format UDZO \
  -imagekey zlib-level=9 \
  -quiet

rm -rf "$STAGING_DIR"

mv "$DMG_NAME" "$DIST_DIR/"
mv "$APP_BUNDLE" "$DIST_DIR/"

echo "Created: dist/$DMG_NAME"
