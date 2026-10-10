# Controls and Layout

[日本語](../guide_ja/controls-and-layout.html)

UIng provides native controls for displaying text, accepting input, choosing
values, showing progress, working with menus, and presenting tabular data.
Common starting points include `Label`, `Button`, `Entry`, `Checkbox`,
`Combobox`, `Slider`, and `ProgressBar`.

## Containers

A window has one child. Use a container when an interface needs more than one
control:

- `Box` arranges children horizontally or vertically.
- `Form` aligns labels with input controls.
- `Grid` places controls in rows and columns.
- `Group` places a title around one child.
- `Tab` organizes controls into pages.

This example arranges controls in a vertical Box:

<pre><code class="crystal">
box = UIng::Box.new(:vertical, padded: true)
box.append(UIng::Label.new("Name"))
box.append(UIng::Entry.new)
box.append(UIng::Button.new("Save"))

window.child = box
</code></pre>

Use `box.append(editor, stretchy: true)` to give an editor the remaining height.
For complex layouts, nest containers and assign the outermost one to the Window (see the [Box example](widget-box.html) and [control gallery](https://github.com/kojix2/uing/tree/main/examples/gallery)).

## Space allocation and alignment

Allocating extra space and placing children within it are separate decisions.

| Container | Space allocation | Placement within that space |
| --- | --- | --- |
| Box | `stretchy` distributes space along the layout direction | A stretchy child fills that direction |
| Form | `stretchy` distributes height | A stretchy control grows vertically; controls always fill the input column horizontally |
| Grid | `hexpand` and `vexpand` expand columns and rows | `halign` and `valign` set alignment; `:fill` fills the allocation |

Box and Form combine allocation and stretching, with no separate `fill` argument. Use [Grid](widget-grid.html) to control expansion and alignment independently. `padded` sets gaps between children; `margined` sets outer margins. Neither controls stretching.

<a id="platform-differences"></a>

## Platform differences

Diagrams show layout bounds, which may differ from a control's visible parts. macOS Spinbox centers its input field and stepper at their natural heights; Windows sizes the input field to the allocated height. Minimum sizes, text placement, and standard spacing also vary by OS.

## Widget guides

- Window, menus, and dialogs: [Window](widget-window.md),
  [Toolbar](widget-toolbar.md), [Menu](widget-menu.md), and
  [Dialogs](widget-dialogs.md)
- Input and display: [Button](widget-button.md), [Checkbox](widget-checkbox.md),
  [Entry](widget-entry.md), [Combobox](widget-combobox.md),
  [EditableCombobox](widget-editable-combobox.md), [RadioButtons](widget-radio-buttons.md),
  [Slider](widget-slider.md), and [Spinbox](widget-spinbox.md)
- Specialized controls: [ColorButton](widget-color-button.md),
  [DateTimePicker](widget-date-time-picker.md), [FontButton](widget-font-button.md),
  [ImageView](widget-image-view.md), [Label](widget-label.md),
  [MultilineEntry](widget-multiline-entry.md), [ProgressBar](widget-progress-bar.md),
  and [Separator](widget-separator.md)
- Layout: [Box](widget-box.md), [Tab](widget-tab.md), [Form](widget-form.md),
  [Group](widget-group.md), and [Grid](widget-grid.md)
- Data and drawing: [Table](widget-table.md) and [Area](widget-area.md)
