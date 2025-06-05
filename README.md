# UIng

[![test](https://github.com/kojix2/uing/actions/workflows/ci.yml/badge.svg)](https://github.com/kojix2/uing/actions/workflows/ci.yml)
[![Lines of Code](https://img.shields.io/endpoint?url=https%3A%2F%2Ftokei.kojix2.net%2Fbadge%2Fgithub%2Fkojix2%2Fuing%2Flines)](https://tokei.kojix2.net/github/kojix2/uing)
[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/kojix2/uing)

**UIng** is a Crystal binding for [libui-ng](https://github.com/libui-ng/libui-ng)

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

## Installation

Add the dependency to your `shard.yml`:

```yaml
dependencies:
  uing:
    github: kojix2/uing
```

The required libui library is automatically downloaded via postinstall.

To download manually: `crystal run download.cr`

## Usage

```crystal
require "uing"

UIng.init

window = UIng::Window.new("Hello World", 300, 200)
window.on_closing do
  UIng.quit
  1
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

For more examples, see [examples](examples).

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
      <td><strong>Middle-Level</strong></td>
      <td><code>src/uing.cr</code></td>
      <td><code>UIng.button_text</code>, etc.</td>
      <td>Handles memory management</td>
    </tr>
    <tr>
      <td><strong>Low-Level</strong></td>
      <td><code>src/uing/lib_ui/lib_ui.cr</code></td>
      <td><code>UIng::LibUI.new_button</code>, etc.</td>
      <td>Direct bindings to libui</td>
    </tr>
  </tbody>
</table>

We are currently in the process of replacing the MethodMissing mechanism. The middle level API is being phased out.

## Memory Safety

UIng has been enhanced with comprehensive memory safety improvements:

- **Instance-level management**: Each UI component maintains its own callback references
- **GC protection**: All callback functions are properly protected from Crystal's garbage collector
- **Crash prevention**: Eliminates segmentation faults caused by accessing freed callback memory

This ensures stable operation even with complex callback scenarios and long-running applications.

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

### MSVC Setup

Use Developer Command Prompt or add Windows Kits path:

```powershell
$env:Path += ";C:\Program Files (x86)\Windows Kits\10\bin\10.0.22621.0\x64"
```

## Closures and Limitations

Crystal blocks passed as callbacks to C functions are captured blocks. The mid-level API implements closures using the Box class to work around limitations. The recent memory safety improvements have resolved most callback-related crashes.

## Development

- `UIng::LibUI` is the module for direct C bindings
- Use [crystal_lib](https://github.com/crystal-lang/crystal_lib) to generate low-level bindings
- When adding new UI components, follow the established callback management patterns
- libui libraries are generated using GitHub Actions at [kojix2/libui-ng](https://github.com/kojix2/libui-ng) in the pre-build branch.

## Contributing

- Fork this repository
- Report bugs and submit pull requests
- Improve documentation
- Test memory safety improvements

## License

MIT License
