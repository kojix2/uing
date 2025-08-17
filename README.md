# UIng

[![test](https://github.com/kojix2/uing/actions/workflows/ci.yml/badge.svg)](https://github.com/kojix2/uing/actions/workflows/ci.yml)
[![Lines of Code](https://img.shields.io/endpoint?url=https%3A%2F%2Ftokei.kojix2.net%2Fbadge%2Fgithub%2Fkojix2%2Fuing%2Flines)](https://tokei.kojix2.net/github/kojix2/uing)
[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/kojix2/uing)

UIng is a Crystal binding for [libui-ng](https://github.com/libui-ng/libui-ng).

libui-ng uses the native APIs of each platform: Win32 API and GDI+ on Windows, Cocoa on macOS, and GTK3 and Cairo on Linux.
You get windows, buttons, text boxes, menus, dialogs, drawing areas, and other standard widgets with the look and feel of each OS. The binary size is small.

<table>
  <thead>
    <tr>
      <th>Windows</th>
      <th>Mac</th>
      <th>Linux</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><img src="https://user-images.githubusercontent.com/5798442/103118046-900ea780-46b0-11eb-81fc-32626762e4df.png"></td>
      <td><img src="https://user-images.githubusercontent.com/5798442/103118059-99980f80-46b0-11eb-9d12-324ec4d297c9.png"></td>
      <td><img src="https://user-images.githubusercontent.com/5798442/103118068-a0bf1d80-46b0-11eb-8c5c-3bdcc3dcfb26.png"></td>
    </tr>
  </tbody>
</table>

## Quick Start

Clone the repository and try the examples:

```sh
git clone https://github.com/kojix2/uing
cd uing
crystal run download.cr
crystal run examples/control_gallery.cr
```

### Windows MSVC Setup

For Windows users using MSVC, use Developer Command Prompt or add Windows Kits path:

```powershell
$env:Path += ";C:\Program Files (x86)\Windows Kits\10\bin\10.0.22621.0\x64"
```

## Installation

Add the dependency to your `shard.yml`:

```yaml
dependencies:
  uing:
    github: kojix2/uing
```

The required libui-ng binary is automatically downloaded from the [kojix2/libui-ng GitHub Releases](https://github.com/kojix2/libui-ng/releases) via postinstall.

## Supported Platforms

- macOS: x86_64 (64-bit), ARM64 (Apple Silicon)
- Linux: x86_64 (64-bit), ARM64
- Windows: x86_64 (64-bit, MSVC and MinGW), x86 (32-bit, MSVC only)

## Usage

```crystal
require "uing"

UIng.init

window = UIng::Window.new("Hello World", 300, 200)
window.on_closing do
  UIng.quit
  true
end

button = UIng::Button.new("Click me")
button.on_clicked do
  UIng.msg_box(window, "Info", "Button clicked!")
end

window.set_child(button)
window.show

UIng.main
UIng.uninit
```

### DSL style

```crystal
require "uing"

UIng.init do
  UIng::Window.new("Hello World", 300, 200) { |win|
    on_closing { UIng.quit; true }
    set_child {
      UIng::Button.new("Click me") {
        on_clicked {
          UIng.msg_box(win, "Info", "Button clicked!")
        }
      }
    }
    show
  }

  UIng.main
end
```

Note: The DSL style is implemented using Crystal's `with ... yield` syntax internally.

## Examples

The `examples/control_gallery.cr` script shows most of the available controls and features in one window.  
You can run it with:

```
crystal run examples/control_gallery.cr
```

For more examples, see the [examples](examples) directory.

## API Levels

<table>
  <thead>
    <tr>
      <th><strong>Level</strong></th>
      <th><strong>Defined in</strong></th>
      <th><strong>Example</strong></th>
      <th><strong>Description</strong></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><strong>High-Level</strong></td>
      <td><code>src/uing/*.cr</code></td>
      <td><code>button.on_clicked { }</code>, etc.</td>
      <td>Object-oriented API</td>
    </tr>
    <tr>
      <td><strong>Low-Level</strong></td>
      <td><code>src/uing/lib_ui/lib_ui.cr</code></td>
      <td><code>UIng::LibUI.new_button</code>, etc.</td>
      <td>Direct bindings to libui</td>
    </tr>
  </tbody>
</table>

- Almost all basic control functions such as `Window`, `Label`, and `Button` are covered.
- APIs for advanced controls such as `Table` and `Area` are also provided. However, these are still under development and there may still be memory management issues.

## Memory Safety

- Most callbacks are stored as instance variables of their respective controls, which protects them from garbage collection (GC). Some callbacks are stored as UIng class variables, which serves the same purpose.

- Instances of a control are passed as arguments to a parent control's append or set_child method. This establishes a reference from the parent to the child, creating a reference chain such as Window -> Box -> Button. This chain prevents the Garbage Collector (GC) from collecting the Button object (and its callbacks), thus avoiding a segmentation fault as long as the Window is present.

- Some root components, such as Window and Menu, are stored as class variables to ensure protection from GC. This may cause memory leaks, but is acceptable for now.

- The use of `finalize` is intentionally avoided in certain cases because the non-deterministic timing of memory deallocation by the GC is often incompatible with libui. Instead, RAII-style API is provided that automatically calls the free method upon exiting a block, relieving users of the need to call free manually.

## Windows Setup

### Hide Console Window

MinGW:

```
crystal build app.cr --link-flags "-mwindows"
```

MSVC:

```
crystal build app.cr --link-flags=/SUBSYSTEM:WINDOWS
```

## Closures in Low-Level Contexts

- Many methods support Crystal closures because the underlying libui-ng functions accept a `data` parameter.

- In some low-level APIs, such as function pointers assigned to struct members, no `data` can be passed. UIng works around this by using struct inheritance and boxed data to support closures in these cases.

- This approach is used in controls like `Table` and `Area`.

## Development

- `UIng::LibUI` is the module for direct C bindings
- Initially, [crystal_lib](https://github.com/crystal-lang/crystal_lib) was used to generate low-level bindings
  　　- However, it required many manual conversions, such as changing LibC::Int to Bool. Currently, it is better to use AI.
- When adding new UI components, follow the established callback management patterns
- libui libraries are generated using GitHub Actions at [kojix2/libui-ng](https://github.com/kojix2/libui-ng) in the pre-build branch.

Note:  
This project was developed with the assistance of generative AI.  
While kojix2 prefers Vibe Coding, this library is not a product of Vibe Coding. it has been created with a good amount of manual work and human review.

## Contributing

- Fork this repository
- Report bugs and submit pull requests
- Improve documentation
- Test memory safety improvements

## License

MIT License
