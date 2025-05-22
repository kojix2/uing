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

## macOS App Packaging

Create a standalone macOS application bundle (.app) and disk image (.dmg):

```bash
# Run the packaging script
./build-mac.sh
```

This script will:
1. Install dependencies (`shards install`)
2. Build the application with release optimizations (`shards build --release`)
3. Package the application as a .app bundle
4. Automatically include any Homebrew dependencies
5. Create a distributable .dmg file
6. Place all distribution files in the `dist/` directory

## MD5 File Format

```
d41d8cd98f00b204e9800998ecf8427e file1.txt
900150983cd24fb0d6963f7d28e17f72 file2.txt
```

Each line contains an MD5 hash followed by a space and then the filename.
