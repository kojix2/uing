# Test architecture

Tests are grouped by execution requirements, then by the type they exercise:

| Directory | Purpose |
| --- | --- |
| `headless/` | State, ownership, conversion, and C callback tests without GUI initialization |
| `native/` | Tests requiring native GUI initialization or the event loop |
| `support/` | Explicitly required shared fakes and test accessors |
| `fixtures/` | Programs that run in a separate process |

## Running tests

```sh
crystal spec
crystal spec spec/headless
crystal spec spec/headless -- --order 12345
UING_NATIVE_GUI_TESTS=1 crystal spec spec/native
```

All tests require the linked libui-ng library. Native flags must be set at
compile time. On Linux without a display, prefix the native command with
`xvfb-run -a env`.

ImageBuffer tests also require a compatible library and the additional flag:

```sh
xvfb-run -a env UING_NATIVE_GUI_TESTS=1 UING_IMAGE_BUFFER_TESTS=1 crystal spec spec/native
```

A single file can be run with `crystal spec path/to/type_spec.cr`, using the
same flags required by its suite. CI runs headless tests on all supported jobs
and native tests on Linux x64, macOS ARM64, and Windows MSVC.

## Placement rules

- Follow source namespaces: `area/draw/context_spec.cr` tests `Area::Draw::Context`.
- Keep lifetime, validation, conversion, and DSL cases with their owning type.
- Test shared Control/container contracts separately from type-specific rules.
- Keep local fakes beside their cases; explicitly require shared support.
- Each spec must run independently and must not require another spec.
- Native features own initialization and shutdown. Menu cases use a fresh
  runtime and create menus before any Window. Event-loop waits need deadlines.

The public entry points are `uing` and `uing/crimage`. Source types use a
`type.cr` file with nested types under `type/`.

Coverage is behavioral, not exhaustive for every accessor or OS interaction.
The gallery screenshot workflow checks rendered appearance across platforms;
these screenshots are diagnostic artifacts, not pixel-perfect golden tests.
