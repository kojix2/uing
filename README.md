# UIng

[![test](https://github.com/kojix2/uing/actions/workflows/ci.yml/badge.svg)](https://github.com/kojix2/uing/actions/workflows/ci.yml)
[![Lines of Code](https://img.shields.io/endpoint?url=https%3A%2F%2Ftokei.kojix2.net%2Fbadge%2Fgithub%2Fkojix2%2Fuing%2Flines)](https://tokei.kojix2.net/github/kojix2/uing)

**UIng** is yet another Crystal binding for **[libui-ng](https://github.com/libui-ng/libui-ng)** or **[libui-dev](https://github.com/petabyt/libui-dev)**.

| Windows                                                                                                          | Mac                                                                                                              | Linux                                                                                                            |
| ---------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| <img src="https://user-images.githubusercontent.com/5798442/103118046-900ea780-46b0-11eb-81fc-32626762e4df.png"> | <img src="https://user-images.githubusercontent.com/5798442/103118059-99980f80-46b0-11eb-9d12-324ec4d297c9.png"> | <img src="https://user-images.githubusercontent.com/5798442/103118068-a0bf1d80-46b0-11eb-8c5c-3bdcc3dcfb26.png"> |

## 🔶 Installation

Add the dependency to your `shard.yml`.

```sh
dependencies:
  uing:
    github: kojix2/uing
```

### ⇩ Downloading Binaries

The required libui library is automatically downloaded via [`postinstall`](https://github.com/kojix2/uing/blob/main/shard.yml).

Because the original libui-ng project does not provide prebuilt binaries, this project uses the following sources:

| OS                | Binary Source                                                                                       |
| ----------------- | --------------------------------------------------------------------------------------------------- |
| MacOS / Linux / Windows (MSVC) | Builds from [kojix2/libui-ng](https://github.com/kojix2/libui-ng), [pre-build](https://github.com/kojix2/libui-ng/tree/pre-build) branch |
| Windows (Mingw-w64) | Prebuilt binaries from [libui-dev](https://github.com/petabyt/libui-dev/releases)      |

To download it manually: `crystal run download.cr`

#### Setting up on Windows (MSVC)

If you're using MSVC, you can either:

- Option 1: Use the Developer Command Prompt for Visual Studio
- Option 2: Run manually from any terminal

```cmd
cmd /c "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\VsDevCmd.bat" "&&" crystal build examples/control_gallery.cr
```

- Option 3: Add the Windows Kits path manually:

```powershell
$env:Path += ";C:\Program Files (x86)\Windows Kits\10\bin\10.0.22621.0\x64"
```

This helps prevent errors like: "LINK : fatal error LNK1158: cannot run 'mt.exe'".

### Using Your Own libui Build

The default link flag is defined in [lib_ui.cr](src/uing/lib_ui/lib_ui.cr). Edit as needed.

## 🔶 Usage

The Control gallery example uses a high-level API.

```sh
crystal build examples/control_gallery.cr
./control_gallery
```

### Basic Example

High level API:

```crystal
require "../src/uing"

UIng.init

window = UIng::Window.new("hello world", 300, 200, 1)
window.on_closing do
  UIng.quit
  1
end

button = UIng::Button.new("Button")
button.on_clicked do
  UIng.msg_box(window, "Information", "You clicked the button")
  0
end

window.set_child(button)
window.show

UIng.main
UIng.uninit
```

Middle level API:

```crystal
require "../src/uing"

UIng.init

window = UIng.new_window("hello world", 300, 200, 1)
UIng.window_on_closing(window) do
  UIng.quit
  1
end

button = UIng.new_button("Button")
UIng.button_on_clicked(button) do
  UIng.msg_box(window, "Information", "You clicked the button")
  0
end

UIng.window_set_child(window, button)
UIng.control_show(window)

UIng.main
UIng.uninit
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
  - Methods generated by the MethodMissing macro currently have two limitations in interpreting blocks. (1) Blocks with arguments are not available. (2) The return type is inferred from the code. Therefore, you may need to return Nil if the return value should be void. If you are not sure, you should call the Middle Level API.

### Hide Console Window on Windows

#### MinGW

```sh
crystal build examples/basic_window.cr --link-flags "-mwindows"
```

#### MSVC

```sh
crystal build examples/basic_window.cr --link-flags=/SUBSYSTEM:WINDOWS
```

**Note:** The program will crash if you attempt to output to the console.

### Static Linking

At present, I have not been able to generate an executable that functions correctly through static linking on any platform.
Your contributions are welcome.

## 🔶 Closures and Their Limitations

Crystal has two types of blocks. One is the block that is inlined at compile time and is mainly used with yield. The other is the captured block. Blocks passed as callbacks to C functions are always captured blocks. However, closures do not work correctly with low-level bindings. When referencing variables outside the block, the program detects the anomaly and terminates immediately (note that this does not throw an exception, and it is different from a segmentation fault). To work around this issue, the mid-level API implements closures using the Box class.

On the other hand, the real problem arises when storing callback functions in the fields of a structure and then passing them to C. In this case, since there is no user data, the closures may not function as expected. There is still no definitive solution for this.

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

Many unix tools are available on Windows (MinGW).

- `gdb` can be used for debugging.
- `ldd` can be used to check dependencies.
- `strace` can be used to trace system calls.
- `objdump` can be used to disassemble.

## 🔶 Contributing

You can contribute to this project by:

- ☑ Forking this repository
- ☑ Reporting bugs
- ☑ Fixing bugs and submitting pull requests
- ☑ Improving documentation
- ☑ Suggesting or adding new features

## 🔶 License

This project is licensed under the **MIT License**.
