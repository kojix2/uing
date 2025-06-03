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
- libmpv library

## Setup

### macOS

```bash
brew install mpv
cd examples/video_player
shards install
shards build
```

**Note**: On macOS, the video player uses mpv's "gpu" output driver for hardware-accelerated rendering with Vulkan/Metal backend.

### Windows (with RIDK)

```bash
ridk enable
ridk exec pacman -S mingw-w64-x86_64-mpv
cd examples/video_player
ridk exec shards install
ridk exec shards build
```

**Note**: On Windows, the video player is designed to use mpv's "direct3d" or "gpu" output driver for hardware-accelerated rendering with DirectX backend.

## Usage

```bash
# Play default video (Big Buck Bunny)
./bin/video_player

# Play a local file
./bin/video_player "path/to/your/video.mp4"

# Play a URL
./bin/video_player "https://example.com/video.mp4"
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

## License

MIT License
