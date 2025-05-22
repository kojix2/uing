#!/bin/bash
set -e

# Application configuration
APP_NAME="md5checker"
APP_NAME_CAPITALIZED="Md5checker"  # Capitalized version of APP_NAME
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

# --- Step 0: Install dependencies and build the application ---
echo "📦 Installing dependencies..."
shards install

echo "🔨 Building application with release optimizations..."
shards build --release

# --- Step 1: Initialize directories ---
echo "🧹 Cleaning up previous builds..."
rm -rf "$APP_BUNDLE" "$DMG_NAME" "$STAGING_DIR" "$DIST_DIR"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR" "$FRAMEWORKS_DIR" "$DIST_DIR"

# --- Step 2: Create .app bundle structure ---
echo "📦 Creating .app bundle structure..."
cp "$EXECUTABLE_PATH" "$MACOS_DIR/$APP_NAME"
chmod +x "$MACOS_DIR/$APP_NAME"

# Copy application icon
echo "🎨 Adding application icon..."
if [ -f "$ICON_PATH" ]; then
  cp "$ICON_PATH" "$RESOURCES_DIR/$ICON_NAME.icns"
  echo "✅ Icon added: $ICON_PATH → $RESOURCES_DIR/$ICON_NAME.icns"
else
  echo "⚠️ Warning: Icon file not found at $ICON_PATH"
fi

# Create Info.plist file
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
  <string>1.0</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleIconFile</key>
  <string>$ICON_NAME</string>
</dict>
</plist>
EOF

# --- Step 3: Detect and bundle Homebrew libraries ---
echo "🔍 Detecting Homebrew libraries with otool..."
otool -L "$MACOS_DIR/$APP_NAME" \
| awk '{print $1}' \
| grep "^/opt/homebrew" \
| while read -r lib; do
    base=$(basename "$lib")
    echo "📚 $lib → Frameworks/$base"
    cp "$lib" "$FRAMEWORKS_DIR/$base"
    install_name_tool -change "$lib" "@executable_path/../Frameworks/$base" "$MACOS_DIR/$APP_NAME"
done

# --- Step 4: Create professional DMG file ---
echo "🚚 Preparing DMG staging area..."
mkdir -p "$STAGING_DIR"
cp -R "$APP_BUNDLE" "$STAGING_DIR/"

# Create symbolic link to /Applications
echo "🔗 Creating Applications folder symlink..."
ln -s /Applications "$STAGING_DIR/Applications"

echo "💽 Creating DMG file..."
hdiutil create "$DMG_NAME" \
  -volname "$VOL_NAME" \
  -srcfolder "$STAGING_DIR" \
  -fs HFS+ \
  -format UDZO \
  -imagekey zlib-level=9 \
  -quiet

# Clean up
rm -rf "$STAGING_DIR"

# --- Step 5: Collect artifacts in dist/ directory ---
echo "📁 Moving artifacts to dist/ directory..."
mv "$DMG_NAME" "$DIST_DIR/"
mv "$APP_BUNDLE" "$DIST_DIR/"

# --- Complete ---
echo ""
echo "✅ Build completed successfully! Artifacts:"
ls -lh "$DIST_DIR"
echo ""
echo "🚀 Distribution file: dist/$DMG_NAME"
