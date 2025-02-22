# UIng

[![test](https://github.com/kojix2/uing/actions/workflows/ci.yml/badge.svg)](https://github.com/kojix2/uing/actions/workflows/ci.yml)

Yet another crystal binding for [libui-ng](https://github.com/libui-ng/libui-ng) or [libui-dev](https://github.com/petabyt/libui-dev)

## Installation

The Crystal language believes that libui should be statically linked rather than as a shared library.

The libui project does not distribute pre-compiled binaries. Here, for MacOS and Linux, we use builds from the workflow in repository kojix2/libui-ng; for Windows, we use binaries distributed with libui-dev.

To download the binaries, run the download script.

```
crystal run download.cr
```

## Usage

See [examples](examples).

- Notes:
  - On Windows, libui-ng's msg_box implementation uses TaskDialog. ComCtl32.dll version6 is required to call TaskDialog. The standard ComCtl32 is version 5, so a manifest file is required.

### Closures are not always possible

- A function pointer in C is a Proc in Crystal.
  - If data can be passed as an argument, it can be a closure, but not always; if data cannot be passed, it works only if the Proc is not a closure.

## Development

1. Low-level bindings are located in `src/uing/lib_ui/lib_ui.cr`.

- `UIng::LibUI.new_window`, `UIng::LibUI::AreaHandler.new`, etc.

2. Middle-level bindings are located in `src/uing.cr`. `UIng.new_window` etc.

- `UIng::Window.new`, `UIng::AreaHandler.new`, `UIng::AreaDrawParams.new(ref_ptr)`, etc.

3. High-level object-oriented bindings are not yet implemented, and parhaps never will be, but they should be found in `src/uing/*.cr`.

- `Window = UIng::Window.new`, `window.on_closing { |w| ... }`, etc.

- Enums are defined under `UIng` module. Both low-level and high-level bindings use them.
- The Crystal object corresponding to a C structure may have a reference pointer, or it may have the structure. Crystal objects have structure if it is necessary to allocate memory for the structure on the Crystal side. Otherwise, it should hold the reference.

- History: https://forum.crystal-lang.org/t/6361
- Rules:
  - `UIng::LibUI` is a module for binding.
  - Use [crystal_lib](https://github.com/crystal-lang/crystal_lib) to create low-level bindings. You will need to modify the generated code.
  - [Passing a Proc to a C function](https://crystal-lang.org/api/1.12.1/Proc.html#passing-a-proc-to-a-c-function)

### Windows

Windows is very difficult to deal with.

First, there is the MSVC version of Crystal and the MingGW version of Crystal, which behave quite differently and need to be considered separately. It is not clear which Crystal will be more popular in the future.

Also, either msvcrt or ucrt must be used, but they often conflict.

An important point is the Comctl32 version specification. libui-ng and libui-dev depend on Comctl32 version 6 or later, but require a manifest file to specify the version. For example, TaskDialog depends on the new Comctl32.

I have tried removing TaskDialog. The build succeeds but does not work properly. As it turns out, there are other dependencies on Comctl32 besides TaskDialog. Also, the widget looks old and should not depend on the old Comctl32.

The method of including manifest files also differs between MSVC and MinGW.

libui-ng is more MSVC oriented, while libui-dev seems to be developed based on MinGW.

For debugging, you can use the MinGW version of gdb.

## Contributing

- Fork this repository
- Report bugs
- Fix bugs and submit pull requests
- Write, clarify, or fix documentation
- Suggest or add new features

## License

MIT
