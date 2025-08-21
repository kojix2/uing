# UIng

[![test](https://github.com/kojix2/uing/actions/workflows/ci.yml/badge.svg)](https://github.com/kojix2/uing/actions/workflows/ci.yml)
[![Lines of Code](https://img.shields.io/endpoint?url=https%3A%2F%2Ftokei.kojix2.net%2Fbadge%2Fgithub%2Fkojix2%2Fuing%2Flines)](https://tokei.kojix2.net/github/kojix2/uing)
[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/kojix2/uing)

UIng is a Crystal binding for [libui-ng](https://github.com/libui-ng/libui-ng).

libui-ng uses the native APIs of each platform: Win32 API, Direct2D, and DirectWrite on Windows; Cocoa (AppKit) on macOS; and GTK+ 3.10+ and Pango on Linux/Unix.
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
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/refs/heads/screenshots/control_gallery-windows.png"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/refs/heads/screenshots/control_gallery-macos.png"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/refs/heads/screenshots/control_gallery-ubuntu.png"></td>
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
  window.msg_box("Info", "Button clicked!")
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
          win.msg_box("Info", "Button clicked!")
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

## Limitations

libui-ng is an excellent library, but supporting three platforms comes with some notable limitations:

1. Image display is not supported. While tables can display images, the image sizes vary across platforms. (It is possible to display videos in areas using libmpv though.)

2. Grid layout is broken on macOS.

3. Precise widget positioning is not possible. Control placement is intentionally coarse and cannot be specified numerically. This is likely an intentional constraint to ensure consistent behavior across all three platforms.

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

## Gallery

This gallery shows screenshots of example on three platforms (Ubuntu, Windows, macOS).  
Images are automatically generated and stored in the `screenshots` branch.

### Window

<table>
  <thead>
    <tr>
      <th>Control</th>
      <th>Ubuntu</th>
      <th>Windows</th>
      <th>macOS</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><a href="examples/gallery/basic_window.cr">Window</a></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_window-ubuntu.png" alt="basic_window-ubuntu"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_window-windows.png" alt="basic_window-windows"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_window-macos.png" alt="basic_window-macos"></td>
    </tr>
  </tbody>
</table>

### Control

<table>
  <thead>
    <tr>
      <th>Control</th>
      <th>Ubuntu</th>
      <th>Windows</th>
      <th>macOS</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><a href="examples/gallery/basic_button.cr">Button</a></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_button-ubuntu.png" alt="basic_button-ubuntu"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_button-windows.png" alt="basic_button-windows"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_button-macos.png" alt="basic_button-macos"></td>
    </tr>
    <tr>
      <td><a href="examples/gallery/basic_checkbox.cr">Checkbox</a></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_checkbox-ubuntu.png" alt="basic_checkbox-ubuntu"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_checkbox-windows.png" alt="basic_checkbox-windows"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_checkbox-macos.png" alt="basic_checkbox-macos"></td>
    </tr>
    <tr>
      <td><a href="examples/gallery/basic_color_button.cr">ColorButton</a></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_color_button-ubuntu.png" alt="basic_color_button-ubuntu"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_color_button-windows.png" alt="basic_color_button-windows"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_color_button-macos.png" alt="basic_color_button-macos"></td>
    </tr>
    <tr>
      <td><a href="examples/gallery/basic_combobox.cr">Combobox</a></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_combobox-ubuntu.png" alt="basic_combobox-ubuntu"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_combobox-windows.png" alt="basic_combobox-windows"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_combobox-macos.png" alt="basic_combobox-macos"></td>
    </tr>
    <tr>
      <td><a href="examples/gallery/basic_date_time_picker.cr">DateTimePicker</a></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_date_time_picker-ubuntu.png" alt="basic_date_time_picker-ubuntu"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_date_time_picker-windows.png" alt="basic_date_time_picker-windows"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_date_time_picker-macos.png" alt="basic_date_time_picker-macos"></td>
    </tr>
    <tr>
      <td><a href="examples/gallery/basic_editable_combobox.cr">EditableCombobox</a></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_editable_combobox-ubuntu.png" alt="basic_editable_combobox-ubuntu"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_editable_combobox-windows.png" alt="basic_editable_combobox-windows"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_editable_combobox-macos.png" alt="basic_editable_combobox-macos"></td>
    </tr>
    <tr>
      <td><a href="examples/gallery/basic_entry.cr">Entry</a></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_entry-ubuntu.png" alt="basic_entry-ubuntu"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_entry-windows.png" alt="basic_entry-windows"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_entry-macos.png" alt="basic_entry-macos"></td>
    </tr>
    <tr>
      <td><a href="examples/gallery/basic_font_button.cr">FontButton</a></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_font_button-ubuntu.png" alt="basic_font_button-ubuntu"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_font_button-windows.png" alt="basic_font_button-windows"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_font_button-macos.png" alt="basic_font_button-macos"></td>
    </tr>
    <tr>
      <td><a href="examples/gallery/basic_label.cr">Label</a></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_label-ubuntu.png" alt="basic_label-ubuntu"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_label-windows.png" alt="basic_label-windows"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_label-macos.png" alt="basic_label-macos"></td>
    </tr>
    <tr>
      <td><a href="examples/gallery/basic_multiline_entry.cr">MultilineEntry</a></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_multiline_entry-ubuntu.png" alt="basic_multiline_entry-ubuntu"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_multiline_entry-windows.png" alt="basic_multiline_entry-windows"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_multiline_entry-macos.png" alt="basic_multiline_entry-macos"></td>
    </tr>
    <tr>
      <td><a href="examples/gallery/basic_progressbar.cr">Progressbar</a></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_progressbar-ubuntu.png" alt="basic_progressbar-ubuntu"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_progressbar-windows.png" alt="basic_progressbar-windows"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_progressbar-macos.png" alt="basic_progressbar-macos"></td>
    </tr>
    <tr>
      <td><a href="examples/gallery/basic_radio_buttons.cr">RadioButtons</a></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_radio_buttons-ubuntu.png" alt="basic_radio_buttons-ubuntu"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_radio_buttons-windows.png" alt="basic_radio_buttons-windows"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_radio_buttons-macos.png" alt="basic_radio_buttons-macos"></td>
    </tr>
    <tr>
      <td><a href="examples/gallery/basic_separator.cr">Separator</a></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_separator-ubuntu.png" alt="basic_separator-ubuntu"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_separator-windows.png" alt="basic_separator-windows"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_separator-macos.png" alt="basic_separator-macos"></td>
    </tr>
    <tr>
      <td><a href="examples/gallery/basic_slider.cr">Slider</a></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_slider-ubuntu.png" alt="basic_slider-ubuntu"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_slider-windows.png" alt="basic_slider-windows"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_slider-macos.png" alt="basic_slider-macos"></td>
    </tr>
    <tr>
      <td><a href="examples/gallery/basic_spinbox.cr">Spinbox</a></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_spinbox-ubuntu.png" alt="basic_spinbox-ubuntu"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_spinbox-windows.png" alt="basic_spinbox-windows"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_spinbox-macos.png" alt="basic_spinbox-macos"></td>
    </tr>
    </tr>
  </tbody>
</table>

### Container Control

<table>
  <thead>
    <tr>
      <th>Container</th>
      <th>Ubuntu</th>
      <th>Windows</th>
      <th>macOS</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><a href="examples/gallery/basic_box_horizontal.cr">Box (Horizontal)</a></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_box_horizontal-ubuntu.png" alt="basic_box_horizontal-ubuntu"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_box_horizontal-windows.png" alt="basic_box_horizontal-windows"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_box_horizontal-macos.png" alt="basic_box_horizontal-macos"></td>
    </tr>
    <tr>
      <td><a href="examples/gallery/basic_box_vertical.cr">Box (Vertical)</a></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_box_vertical-ubuntu.png" alt="basic_box_vertical-ubuntu"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_box_vertical-windows.png" alt="basic_box_vertical-windows"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_box_vertical-macos.png" alt="basic_box_vertical-macos"></td>
    </tr>
    <tr>
      <td><a href="examples/gallery/basic_tab.cr">Tab</a></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_tab-ubuntu.png" alt="basic_tab-ubuntu"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_tab-windows.png" alt="basic_tab-windows"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_tab-macos.png" alt="basic_tab-macos"></td>
    </tr>
    <tr>
      <td><a href="examples/gallery/basic_form.cr">Form</a></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_form-ubuntu.png" alt="basic_form-ubuntu"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_form-windows.png" alt="basic_form-windows"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_form-macos.png" alt="basic_form-macos"></td>
    </tr>
    <tr>
      <td><a href="examples/gallery/basic_group.cr">Group</a></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_group-ubuntu.png" alt="basic_group-ubuntu"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_group-windows.png" alt="basic_group-windows"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_group-macos.png" alt="basic_group-macos"></td>
    </tr>
    <tr>
      <td><a href="examples/gallery/basic_grid.cr">Grid</a></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_grid-ubuntu.png" alt="basic_grid-ubuntu"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_grid-windows.png" alt="basic_grid-windows"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_grid-macos.png" alt="basic_grid-macos"></td>
    </tr>
    <tr>
      <td><a href="examples/gallery/calculator.cr">Grid (Calculator)</a></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/calculator-ubuntu.png" alt="grid_calculator-ubuntu"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/calculator-windows.png" alt="grid_calculator-windows"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/calculator-macos.png" alt="grid_calculator-macos"></td>
    </tr>
  </tbody>
</table>

Note: Grid Layout does not work as expected on macOS.

### Table

<table>
  <thead>
    <tr>
      <th>Example</th>
      <th>Ubuntu</th>
      <th>Windows</th>
      <th>macOS</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><a href="examples/gallery/basic_table.cr">basic_table</a></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_table-ubuntu.png" alt="basic_table-ubuntu"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_table-windows.png" alt="basic_table-windows"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_table-macos.png" alt="basic_table-macos"></td>
    </tr>
    <tr>
      <td><a href="examples/gallery/advanced_table.cr">advanced_table</a></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/advanced_table-ubuntu.png" alt="advanced_table-ubuntu"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/advanced_table-windows.png" alt="advanced_table-windows"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/advanced_table-macos.png" alt="advanced_table-macos"></td>
    </tr>
  </tbody>
</table>

### Area

<table>
  <thead>
    <tr>
      <th>Example</th>
      <th>Ubuntu</th>
      <th>Windows</th>
      <th>macOS</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><a href="examples/gallery/basic_area.cr">basic_area</a></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_area-ubuntu.png" alt="basic_area-ubuntu"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_area-windows.png" alt="basic_area-windows"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_area-macos.png" alt="basic_area-macos"></td>
    </tr>
    <tr>
      <td><a href="examples/gallery/spirograph.cr">spirograph</a></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/spirograph-ubuntu.png" alt="spirograph-ubuntu"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/spirograph-windows.png" alt="spirograph-windows"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/spirograph-macos.png" alt="spirograph-macos"></td>
    </tr>
    <tr>
      <td><a href="examples/gallery/basic_draw_text.cr">basic_draw_text</a></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_draw_text-ubuntu.png" alt="basic_draw_text-ubuntu"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_draw_text-windows.png" alt="basic_draw_text-windows"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_draw_text-macos.png" alt="basic_draw_text-macos"></td>
    </tr>
  </tbody>
</table>

### Menu

<table>
  <thead>
    <tr>
      <th>Example</th>
      <th>Ubuntu</th>
      <th>Windows</th>
      <th>macOS</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><a href="examples/gallery/basic_menu.cr">basic_menu</a></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_menu-ubuntu.png" alt="basic_menu-ubuntu"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_menu-windows.png" alt="basic_menu-windows"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_menu-macos.png" alt="basic_menu-macos"></td>
    </tr>
  </tbody>
</table>

### Dialog

<table>
  <thead>
    <tr>
      <th>Example</th>
      <th>Ubuntu</th>
      <th>Windows</th>
      <th>macOS</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><a href="examples/gallery/basic_msg_box.cr">basic_msg_box</a></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_msg_box-ubuntu.png" alt="basic_msg_box-ubuntu"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_msg_box-windows.png" alt="basic_msg_box-windows"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_msg_box-macos.png" alt="basic_msg_box-macos"></td>
    </tr>
    <tr>
      <td><a href="examples/gallery/basic_msg_box_error.cr">basic_msg_box_error</a></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_msg_box_error-ubuntu.png" alt="basic_msg_box_error-ubuntu"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_msg_box_error-windows.png" alt="basic_msg_box_error-windows"></td>
      <td><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_msg_box_error-macos.png" alt="basic_msg_box_error-macos"></td>
    </tr>
  </tbody>
</table>

### Timer
