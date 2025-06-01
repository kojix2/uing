# Crystal Video Player

A video player example using libmpv and UIng (Crystal bindings for libui-ng).

## Features

- Video playback using libmpv
- Play/Pause controls
- Video title and dimensions display
- Support for local files and URLs
- Cross-platform GUI using libui-ng

## Requirements

- Crystal language
- Ruby with RIDK (Ruby Installer Development Kit) for MinGW
- libmpv library

## Setup

### 1. Install libmpv (Windows with RIDK)

```bash
# Enable RIDK environment
ridk enable

# Install libmpv development package
ridk exec pacman -S mingw-w64-x86_64-mpv
```

### 2. Install dependencies

```bash
cd examples/video_player
ridk exec shards install
```

### 3. Build the application

```bash
ridk exec crystal build video_player.cr -o bin/video_player.exe
```

## Usage

### Play default video (Big Buck Bunny)
```bash
./bin/video_player.exe
```

### Play a local file
```bash
./bin/video_player.exe "path/to/your/video.mp4"
```

### Play a URL
```bash
./bin/video_player.exe "https://example.com/video.mp4"
```

## Controls

- **Play / Pause button**: Toggle video playback
- **Title label**: Shows the media title (if available)
- **Size label**: Shows video dimensions (width x height)

## Architecture

The video player consists of three main components:

1. **MPV Bindings** (`src/mpv_bindings.cr`): Low-level Crystal bindings for libmpv
2. **MPV Player** (`src/mpv_player.cr`): High-level wrapper class for mpv functionality
3. **Video Player** (`video_player.cr`): Main application with GUI

## Troubleshooting

### Build Issues

If you encounter linking errors:

1. Make sure RIDK is properly enabled: `ridk enable`
2. Verify libmpv is installed: `ridk exec pacman -Qs mpv`
3. Check library paths: `ridk exec pkg-config --libs mpv`

### Runtime Issues

If the application fails to start:

1. Ensure libmpv DLLs are in your PATH or in the same directory as the executable
2. Check that the video file/URL is accessible
3. Verify your system has proper video codecs installed

### Missing DLLs

You may need to copy these DLLs to your `bin/` directory:
- `libmpv-2.dll`
- Various FFmpeg DLLs (libavcodec, libavformat, etc.)

## Based on

This implementation is based on the C example from the mpv project, adapted for Crystal using the UIng library.

## License

MIT License
