# MD5 Checker

A simple MD5 checksum verification tool built with Crystal and UIng.

## Installation

```bash
shards install
```

## Usage

Run the application:

```bash
shards build
bin/md5checker
```

## Application Packaging

### macOS App Packaging

Create a standalone macOS application bundle (.app) and disk image (.dmg):

```bash
# Run the packaging script
./build-mac.sh
```

This script will:
1. Install dependencies (`shards install`)
2. Build the application with release optimizations (`shards build --release`)
3. Package the application as a .app bundle with custom icon
4. Automatically include any Homebrew dependencies
5. Create a professional distributable .dmg file with:
   - Application icon and Applications folder shortcut
   - Installation instructions (README.txt)
6. Place all distribution files in the `dist/` directory

### Windows App Packaging

Create a standalone Windows executable and installer (.exe) using Inno Setup:

```cmd
:: Run the packaging script
build-win.bat
```

This script will:
1. Install dependencies (`shards install`)
2. Build the application with release optimizations (`shards build --release`)
3. Create an Inno Setup script if it doesn't exist
4. Build an installer using Inno Setup
5. Place all distribution files in the `dist/` directory

#### Prerequisites for Windows Packaging

1. Install [Inno Setup](https://jrsoftware.org/isdl.php)
2. Ensure `ISCC.exe` is in your PATH or modify the `ISCC` variable in `build-win.bat`

#### Custom Application Icon for Windows

To use a custom icon:
1. Create a .ico file (Windows icon format)
2. Place it at `resources/app_icon.ico` in the project directory
3. Uncomment the icon line in `md5checker.iss`

### Custom Application Icon

The script automatically includes the application icon from `resources/app_icon.icns`. 
To use your own icon:

1. Create an .icns file (macOS icon format)
2. Place it at `resources/app_icon.icns` in the project directory
3. Run the build script

You can create an .icns file from a PNG image using the following commands:

```bash
# Create iconset directory with multiple sizes
mkdir -p MyIcon.iconset
sips -z 16 16 icon.png --out MyIcon.iconset/icon_16x16.png
sips -z 32 32 icon.png --out MyIcon.iconset/icon_16x16@2x.png
sips -z 32 32 icon.png --out MyIcon.iconset/icon_32x32.png
sips -z 64 64 icon.png --out MyIcon.iconset/icon_32x32@2x.png
sips -z 128 128 icon.png --out MyIcon.iconset/icon_128x128.png
sips -z 256 256 icon.png --out MyIcon.iconset/icon_128x128@2x.png
sips -z 256 256 icon.png --out MyIcon.iconset/icon_256x256.png
sips -z 512 512 icon.png --out MyIcon.iconset/icon_256x256@2x.png
sips -z 512 512 icon.png --out MyIcon.iconset/icon_512x512.png
cp icon.png MyIcon.iconset/icon_512x512@2x.png

# Convert iconset to .icns file
iconutil -c icns MyIcon.iconset
```

## MD5 File Format

```
d41d8cd98f00b204e9800998ecf8427e file1.txt
900150983cd24fb0d6963f7d28e17f72 file2.txt
```

Each line contains an MD5 hash followed by a space and then the filename.
