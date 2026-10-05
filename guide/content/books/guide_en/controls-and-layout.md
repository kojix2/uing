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

The following vertical box keeps its controls together and adds native
spacing between them:

<pre><code class="crystal">
box = UIng::Box.new(:vertical, padded: true)
box.append(UIng::Label.new("Name"))
box.append(UIng::Entry.new)
box.append(UIng::Button.new("Save"))

window.child = box
</code></pre>

The optional `stretchy` argument to `Box#append` controls whether a child uses
the remaining space:

<pre><code class="crystal">
box.append(editor, stretchy: true)
</code></pre>

Build small containers first, nest them as needed, and assign the outermost
container to the window. See the
[control gallery](https://github.com/kojix2/uing/tree/main/examples/gallery)
for examples of each control and layout.

## Widget guides

- Window, menus, and dialogs: [Window](widget-window.md), [Menu](widget-menu.md),
  [Dialogs](widget-dialogs.md)
- Input and display: [Button](widget-button.md), [Checkbox](widget-checkbox.md),
  [Entry](widget-entry.md), [Combobox](widget-combobox.md),
  [EditableCombobox](widget-editable-combobox.md), [RadioButtons](widget-radio-buttons.md),
  [Slider](widget-slider.md), and [Spinbox](widget-spinbox.md)
- Specialized controls: [ColorButton](widget-color-button.md),
  [DateTimePicker](widget-date-time-picker.md), [FontButton](widget-font-button.md),
  [Label](widget-label.md), [MultilineEntry](widget-multiline-entry.md),
  [ProgressBar](widget-progress-bar.md), and [Separator](widget-separator.md)
- Layout: [Box](widget-box.md), [Tab](widget-tab.md), [Form](widget-form.md),
  [Group](widget-group.md), and [Grid](widget-grid.md)
- Data and drawing: [Table](widget-table.md) and [Area](widget-area.md)
