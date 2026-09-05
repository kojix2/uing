# Test architecture

UIng tests are split by the boundary they exercise. A regression should live at
the lowest layer that can reproduce it, with a higher-layer test added only when
the native event loop or rendered UI is part of the behavior.

## Default suite

```sh
crystal spec
```

The specs directly under `spec/` cover Crystal state, ownership rules, value
conversion, and deterministic C callback boundaries. They require the linked
libui-ng library but do not initialize a desktop session. This suite runs on all
supported compiler and OS jobs.

## Native GUI suite

```sh
UING_NATIVE_GUI_TESTS=1 crystal spec spec/native
```

Specs under `spec/native/` initialize libui-ng and pump its real event loop.
They cover behavior that cannot be established with fake pointers, especially
deferred destruction and native destruction notifications. They are opt-in so
local and headless runs of the default suite remain predictable. The GUI
suite runs once per native backend in the existing Linux x64, macOS ARM64, and
Windows MSVC jobs. Linux uses Xvfb; macOS and Windows use their hosted desktop
sessions. It is deliberately kept out of the substantially heavier screenshot
workflow. The other architecture and Windows toolchain jobs retain the default
suite without duplicating the same backend-level scenarios.

Native GUI tests must have an internal deadline and must not depend on screen
coordinates, animation timing, fonts, or pixel output. Visual rendering belongs
to the screenshot workflow; interactive behavior should be driven through the
public API whenever possible.

## Visual suite

The gallery screenshot workflow checks that examples build, launch, and render
on Linux, Windows, and macOS. Screenshots are diagnostic artifacts rather than
pixel-perfect golden tests, because native themes, fonts, and DPI change outside
the library.
