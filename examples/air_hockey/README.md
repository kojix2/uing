# Air Hockey

An air hockey example built with UIng `Area` drawing. Move your mallet with the mouse and play against a simple CPU opponent.

## Requirements

- Crystal 1.0 or later
- shards
- A working UIng runtime environment
  - Linux: GTK 3 runtime
  - macOS: Cocoa/AppKit
  - Windows: Win32/Direct2D/DirectWrite environment used by libui-ng
- Native audio support required by `raudio.cr` when audio is enabled

## Build and Run

Run from this directory:

```sh
cd examples/air_hockey
make run
```

Main Make targets:

```sh
make deps             # Install shard dependencies
make build            # Build bin/air_hockey
make run              # Build and run the game
make build release=1  # Build with --release
make clean            # Remove the generated executable
```

To build directly without the Makefile:

```sh
shards install
crystal build -Dpreview_mt -Dexecution_context src/air_hockey.cr -o bin/air_hockey
./bin/air_hockey
```

## Controls

- Mouse move: move the player mallet
- Click / Space / Enter: serve, or restart after the match ends
- WASD / arrow keys: nudge the mallet

The first side to 7 points wins.

## Implementation Notes

- GUI and drawing: `uing`
  - Uses `UIng::Window` and `UIng::Area`
  - Handles drawing and input through `Area::Handler` draw / mouse / key callbacks
  - Runs the update loop at about 60 FPS with `UIng.timer`
- Audio: `raudio.cr`
  - Sound effects are generated from synthesized WAV data at runtime
  - Background music is played from `assets/bgm.wav`
  - Audio work is separated from the GUI thread using `Fiber::ExecutionContext::Isolated` and `Channel`
- Game logic:
  - Collision handling for the puck, mallets, rails, and goals
  - Simple CPU mallet behavior
  - Projection from table coordinates to a faux-3D screen view

## Environment Variables

```sh
AIR_HOCKEY_AUDIO=0        # Disable all audio
AIR_HOCKEY_BGM=0          # Disable background music only
AIR_HOCKEY_SFX=0          # Disable sound effects only
AIR_HOCKEY_DEBUG=1        # Print debug logs to stderr
AIR_HOCKEY_BGM_FILE=path  # Use a custom BGM WAV file
```

In CI or on machines without an audio device, disable audio like this:

```sh
AIR_HOCKEY_AUDIO=0 make run
```
