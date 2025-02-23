# UIng

[![test](https://github.com/kojix2/uing/actions/workflows/ci.yml/badge.svg)](https://github.com/kojix2/uing/actions/workflows/ci.yml)

**UIng** is yet another Crystal binding for **[libui-ng](https://github.com/libui-ng/libui-ng)** or **[libui-dev](https://github.com/petabyt/libui-dev)**.

| Windows                                                                                                          | Mac                                                                                                              | Linux                                                                                                            |
| ---------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| <img src="https://user-images.githubusercontent.com/5798442/103118046-900ea780-46b0-11eb-81fc-32626762e4df.png"> | <img src="https://user-images.githubusercontent.com/5798442/103118059-99980f80-46b0-11eb-9d12-324ec4d297c9.png"> | <img src="https://user-images.githubusercontent.com/5798442/103118068-a0bf1d80-46b0-11eb-8c5c-3bdcc3dcfb26.png"> |

## 🔶 Installation

### ⇩ Downloading Binaries

```sh
crystal run download.cr
```

Crystal prefers **static linking** for libui rather than using it as a shared library.

The libui project **does not distribute pre-compiled binaries**.  
Therefore, this project uses the following sources to obtain binaries:

| OS                | Binary Source                                                                                       |
| ----------------- | --------------------------------------------------------------------------------------------------- |
| **MacOS / Linux** | Builds from the [kojix2/libui-ng](https://github.com/kojix2/libui-ng) repository (pre-build branch) |
| **Windows**       | Pre-built binaries distributed with [libui-dev](https://github.com/petabyt/libui-dev/releases)      |

### Windows

- **MinGW (mingw-w64-crystal)** is recommended for Windows. UCRT / Clang is not supported because libui-dev is built with MinGW64.
- **MSVC (x86_64-msvc)** is not recommended but can be used with some limitations. Make sure rc.exe is in the PATH.

See: https://crystal-lang.org/install/#windows

## 🔶 Usage

The Control gallery example uses a high-level API.

```sh
crystal build examples/control_gallery.cr
./control_gallery
```

For more details, see [examples](examples).

The middle-level API is reasonably well-implemented, allowing users to access most of libui's functionality. Please start by using this level.

### Binding Levels

| **Level**        | **Defined in**              | **Example**                    | **Description**               |
| ---------------- | --------------------------- | ------------------------------ | ----------------------------- |
| **Low-Level**    | `src/uing/lib_ui/lib_ui.cr` | `UIng::LibUI.new_button`, etc. | Direct bindings to the libui. |
| **Middle-Level** | `src/uing.cr`               | `UIng.button_text`, etc.       | Handles memory management.    |
| **High-Level**   | `src/uing/*.cr`             | `button.on_clicked { }`, etc.  | Custom API or macros.         |

- At the middle level, memory management tasks such as string deallocation are handled.
- The high-level API implementation is limited; the `Control` module provides a `method_missing` macro to handle undefined methods.

## 🔶 Closures and Their Limitations

🚧

## 🔶 Development

### Additional Rules

- `UIng::LibUI` is a **module dedicated to bindings**.
- **Use** [crystal_lib](https://github.com/crystal-lang/crystal_lib) **to generate low-level bindings** (manual modifications required).
- **Passing a Proc to a C function**: [Official Documentation](https://crystal-lang.org/api/1.12.1/Proc.html#passing-a-proc-to-a-c-function).

## 🔶 Windows Compatibility

### ComCtl32 Version Issues

- `libui-ng`'s `msg_box` implementation relies on `TaskDialog`.
- `TaskDialog` requires **ComCtl32.dll version 6**.
- There are other dependencies on version 6 besides `TaskDialog`.
- The standard ComCtl32 is version 5, so a manifest file is necessary.
- For `MSVC` the link flag specifies the manuf.
- For `MinGW`, `comctl32.res` is generated when `download.cr` is run.

### Debugging

- **MinGW version of gdb** can be used for debugging.

## 🔶 Contributing

You can contribute to this project by:

- ☑ Forking this repository
- ☑ Reporting bugs
- ☑ Fixing bugs and submitting pull requests
- ☑ Improving documentation
- ☑ Suggesting or adding new features

## 🔶 License

This project is licensed under the **MIT License**.
