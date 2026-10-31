# Test architecture

Tests are grouped by execution requirements, then by the type they exercise:

| Directory | Purpose |
| --- | --- |
| `headless/` | State, ownership, conversion, and C callback tests without GUI initialization |
| `native/` | Tests requiring native GUI initialization or the event loop |
| `support/` | Explicitly required shared fakes, accessors, and lifecycle helpers |
| `fixtures/` | Programs that run in a separate process |

## Running tests

```sh
crystal spec
crystal spec spec/headless
crystal spec spec/headless -- --order 12345
UING_NATIVE_GUI_TESTS=1 crystal spec spec/native
```

All tests require the linked libui-ng library. Set `UING_NATIVE_GUI_TESTS=1`
at compile time to run the native suite, including ImageBuffer. On Linux
without a display, prefix the native command with `xvfb-run -a env`.

A single file can be run with `crystal spec path/to/type_spec.cr`, using the
same flags required by its suite. CI runs headless tests on all supported jobs
and native tests on Linux x64, macOS ARM64, and Windows MSVC.

## Placement rules

- Follow source namespaces: `area/draw/context_spec.cr` tests `Area::Draw::Context`.
- Keep lifetime, validation, conversion, and DSL cases with their owning type.
- Test shared Control/container contracts separately from type-specific rules.
- Keep native widget behavior in its type's spec, including text, values, and
  selections. Put validation that must reject input before a native call in
  the corresponding headless spec when it can run without GUI initialization.
- Keep shared callback retention, replacement, clearing, and destruction
  contracts in `native/callback_registration_spec.cr`. Add controls and all
  their callback entry points to its explicit matrix as those APIs grow.
- Keep local fakes beside their cases; explicitly require shared support.
  `SpecSupport.with_native_control` gives isolated widget cases a parent Window
  and destroys the complete tree on block exit; the spec still owns runtime
  initialization and shutdown.
- Order examples to explain the type's contract, keeping related operations,
  constraints, and failure cases together. In specs covering several behaviors,
  use nested `describe` groups named for those behaviors (for example,
  `"callback registration"` or `"buffer lifetime"`). Keep valid operations and
  their rejection cases in the same behavior group; short, focused specs can
  remain flat.
- Each spec must run independently and must not require another spec.
- Native features own initialization and shutdown. Menu cases use a fresh
  runtime and create menus before any Window. Event-loop waits need deadlines.

The public entry points are `uing` and `uing/crimage`. Source types use a
`type.cr` file with nested types under `type/`.

Coverage is behavioral, not exhaustive for every accessor or OS interaction.
The gallery screenshot workflow checks rendered appearance across platforms;
these screenshots are diagnostic artifacts, not pixel-perfect golden tests.
