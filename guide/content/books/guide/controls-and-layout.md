# Controls and Layout

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
