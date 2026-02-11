# MD5 Checker

A simple MD5 checksum verification tool built with Crystal and UIng.

## Usage

```bash
shards install
shards build
bin/md5checker
```

## Packaging

### macOS

Create .app bundle and .dmg:
```bash
./build-mac.sh
```

Create .pkg installer (requires fpm):
```bash
./build-mac-pkg.sh
```

### Linux/Debian

Create .deb package (requires fpm):
```bash
./build-deb.sh
```

### Windows

Create installer (requires Inno Setup):
```cmd
build-win.bat
```

## MD5 File Format

```
d41d8cd98f00b204e9800998ecf8427e file1.txt
900150983cd24fb0d6963f7d28e17f72 file2.txt
```

Each line contains an MD5 hash followed by a space and the filename.
