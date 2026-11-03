# Coding Styles

[日本語](../guide_ja/coding-styles.html)

UIng offers two equivalent ways to construct an interface. Both styles use
the same controls and may be mixed in one application.

## Regular API

The regular API is explicit and familiar. This guide mostly uses this form.

<pre><code class="crystal">
window = UIng::Window.new("Hello", 300, 200)
window.child = UIng::Label.new("Hello from UIng")
</code></pre>

## Block-based DSL

The block-based DSL keeps nested layouts visually close to their resulting
control hierarchy:

<pre><code class="crystal">
UIng::Window.new("Hello", 300, 200) {
  child { UIng::Label.new("Hello from UIng") }
}
</code></pre>

Here is an example with a deeper nesting:

<pre><code class="crystal">
UIng.init do
  UIng::Window.new("Hello World", 300, 200) { |win|
    on_closing { UIng.quit; true }
    child {
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
</code></pre>

Both `do ... end` and `{ ... }` pass a block. The following sections explain
the common block forms and their equivalents in the regular API.

## Configure a new object: `new do ... end`

For classes that support block construction, the `new` block lets you call
methods on the new object without an explicit receiver. These two forms
apply the same configuration:

<pre><code class="crystal">
# Regular API
button = UIng::Button.new("Save")
button.on_clicked { puts "Save clicked" }

# Block construction
button = UIng::Button.new("Save") do
  on_clicked { puts "Save clicked" }
end
</code></pre>

`new` returns the created object regardless of the block's last expression.
Creating an object does not attach it to a parent: use `child` or `append`
to attach it. A Window also needs `show` to become visible.

You can receive the object as a block argument, such as `do |button|`.
Use this explicit reference when assigning properties:

<pre><code class="crystal">
button = UIng::Button.new("Save") do |button|
  button.tooltip = "Save the document"
  on_clicked { puts "Save clicked" }
end
</code></pre>

Writing just `tooltip = "..."` assigns a local variable, so write
`button.tooltip = "..."` instead.

Internally, Crystal's `with ... yield` adds a lookup target for method calls
without an explicit receiver; it does not change `self` itself. Outer local
variables remain available. Inside an instance method, instance variables such
as `@entry` still refer to the enclosing instance's variables.

## Use the block result as a child: `child do ... end`

On Window and Group, `child` runs the block immediately and sets the returned
Control as the child. These two forms have the same effect:

<pre><code class="crystal">
window.child = UIng::Label.new("Hello")

window.child do
  UIng::Label.new("Hello")
end
</code></pre>

The block's last expression must return the Control to attach. The `child`
block itself does not switch the implicit receiver. To configure the child,
you can nest its own `new` block:

<pre><code class="crystal">
window.child do
  UIng::Box.new(:vertical, padded: true) do
    append UIng::Label.new("Name")
    append UIng::Entry.new, stretchy: true
  end
end
</code></pre>

Here, the Box's `new` returns the Box, and `child` attaches it to the Window.
The `append` calls inside the Box block are methods on that Box. You could
also write:

<pre><code class="crystal">
box = UIng::Box.new(:vertical, padded: true)
box.append(UIng::Label.new("Name"))
box.append(UIng::Entry.new, stretchy: true)
window.child = box
</code></pre>

## Blocks that attach children

These blocks also run immediately and attach the child returned by their
last expression. They do not switch the implicit receiver. In the table,
`control` and `bar` stand for an existing Control and Toolbar, and `parent`
stands for a Window or Group.

| Target | Block form | Regular API equivalent |
| --- | --- | --- |
| Window, Group | `child { control }` | `parent.child = control` |
| Window, Group | `set_child { control }` | `parent.set_child(control)` (alias for `child`) |
| Box | `append(stretchy: true) { control }` | `box.append(control, stretchy: true)` |
| Form | `append("Name") { control }` | `form.append("Name", control)` |
| Grid | `append(left: 0, top: 0) { control }` | `grid.append(control, left: 0, top: 0)` |
| Grid | `insert_at(existing, :trailing) { control }` | `grid.insert_at(control, existing, :trailing)` |
| Tab | `append("Page", margined: true) { control }` | `tab.append("Page", control, margined: true)` |
| Tab | `insert_at("Page", 0) { control }` | `tab.insert_at("Page", 0, control)` |
| Window | `toolbar { bar }` | `window.toolbar = bar` |

`stretchy`, `margined`, and the Grid's coordinates and layout options have
the same meaning as in the regular API. With an existing parent, you can
use an explicit receiver, such as `box.append(stretchy: true) do ... end`.

Attachment methods such as `Box#append` themselves return `Nil`. If the
last expression in a `child` block is `box.append(...)`, it will not return
a Control. End the block with `box`, or use `Box.new do ... end` as above.

## Menu and toolbar item configuration blocks

These methods first create an item, then run a block where you can call
methods on that item without an explicit receiver. They return the created
item regardless of the block's last expression.

| Target | Methods accepting a configuration block | Object configured and returned |
| --- | --- | --- |
| Menu | `append_item`, `append_check_item` | MenuItem |
| Menu | `append_preferences_item`, `append_about_item`, `append_quit_item` | MenuItem |
| Toolbar | `append_button`, `append_toggle_button` | ToolbarItem |

<pre><code class="crystal">
UIng::Menu.new("File") do
  append_item("Open") do
    set_shortcut('O', UIng::Modifiers::Primary)
    on_clicked { |window| window.try &amp;.open_file }
  end
end
</code></pre>

Here, `append_item` is a method on the Menu; `set_shortcut` and `on_clicked`
are methods on the new MenuItem. You can also receive the item with `do |item|`.

Create menus before the first Window. Quit items use `UIng.on_should_quit`
instead of `on_clicked`. Add toolbar items before its first attachment.
See [Menu](widget-menu.html) and [Toolbar](widget-toolbar.html) for details.

## Event and lifecycle blocks

The same block syntax has different timing and meaning depending on the
method receiving it:

| Form | Timing and purpose |
| --- | --- |
| `new do ... end`, item configuration blocks | Configure the object immediately during construction |
| `child do ... end`, child attachment blocks | Run immediately and attach the returned child |
| `on_clicked do ... end` and similar methods | Register a callback that runs when the event occurs |
| `draw`, `num_rows`, etc. inside `Handler.new` | Register callbacks that run for drawing or data queries |
| `UIng.init do ... end` | Run after initialization and call `uninit` when the block exits |

For example, `draw do ... end` inside `Area::Handler.new do ... end`
registers a drawing callback, just like `handler.draw do ... end`; it does
not draw immediately. Similarly, `num_rows { rows.size }` on a
`Table::Model::Handler` registers the code used when the row count is
queried. See [Area](widget-area.html) and [Table Model and Data](table-model.html).

The `UIng.init` block works with both the regular API and the DSL. See
[Runtime and Lifetime](runtime-and-lifetime.html) for individual resource cleanup.

## Which to choose

- Regular API: suits simple structures and code where you want the flow to
  be explicit.
- DSL: suits deeply nested layouts that read best when written close to
  their hierarchy.

Both styles create the same controls. Either choice is fine as long as the
project stays consistent.
