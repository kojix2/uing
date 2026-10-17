# Runtime and Lifetime

[日本語](../guide_ja/runtime-and-lifetime.html)

A UIng application creates its controls between `UIng.init` and `UIng.main`.
The main loop then waits for native events and invokes the callbacks registered
by the application.

## Application lifecycle

- `UIng.init` initializes libui-ng.
- `window.show` makes a completed window visible.
- `UIng.main` runs the native event loop.
- `UIng.quit` asks that loop to stop.
- `UIng.uninit` releases application-wide resources after the loop ends.

Make sure to call `UIng.uninit` after `UIng.main` so the matching
`UIng.uninit` is not forgotten:

<pre><code class="crystal">
UIng.init

# Build and show the interface here.
UIng.main
UIng.uninit
</code></pre>

`UIng.init` also accepts a block. In that form, `UIng.uninit` is called
automatically after the event loop returns:

<pre><code class="crystal">
UIng.init do
  # Build and show the interface here.
  UIng.main
end
</code></pre>

The block form pairs `init` with `uninit`, including when the block raises an
exception. It does not destroy windows or other resources created inside the
block. Destroy every top-level window before leaving the block, including on
error paths, and free standalone resources according to their ownership rules
below. An exception during setup can otherwise reach `uninit` while a window
is still alive.

## Closing a single window

Normally, you do not need to destroy controls yourself. Stop the event loop
and return `true` from `on_closing`; libui-ng destroys the Window and its
children.

<pre><code class="crystal">
window.on_closing do
  UIng.quit
  true
end
</code></pre>

Do not call `window.destroy` in this callback.

## Control ownership

Some controls contain other controls. The containing control is the parent,
and an attached control is its child. Destroying a parent automatically
destroys all of its children, so normally only the top-level parent needs to
be destroyed.

<pre><code class="crystal">
window = UIng::Window.new("App", 400, 300)
box = UIng::Box.new(:vertical)
button = UIng::Button.new("OK")

box.append(button)
window.child = box

window.destroy # also destroys box and button
</code></pre>

UIng marks the Crystal wrappers for those children as released. They cannot be
used after their parent is destroyed.

Detach a child before reusing it elsewhere:

<pre><code class="crystal">
button.detach
other_box.append(button)
</code></pre>

Detach a child before destroying it individually:

<pre><code class="crystal">
button.detach
button.destroy
</code></pre>

Calling `destroy` on an attached child raises an exception and leaves the
child intact.

- `Window` and `Group` have one child. Assigning `nil` or a new child detaches
  the old child without destroying it.
- `Box`, `Form`, `Tab`, and `Grid` support `delete(child)`; `Box`, `Form`, and
  `Tab` also support `delete(index)`.
- A control without a parent can be destroyed directly.

## Closing a window or application

`UIng.quit` stops the event loop; it does not destroy windows. `UIng.uninit`
releases application-wide resources but does not destroy windows created by
the application. Make sure every top-level window has been destroyed before
calling `UIng.uninit`.

`Window#on_closing` handles the close button. Return `true` to close the
Window or `false` to keep it open. With multiple Windows, do not call
`UIng.quit` unconditionally whenever one Window closes.

`UIng.on_should_quit` handles application-wide requests such as a Quit menu.
Destroy every top-level Window, then return `true`:

<pre><code class="crystal">
UIng.on_should_quit do
  window.destroy unless window.released?
  true
end
</code></pre>

For multiple Windows, repeat this for every top-level Window. `released?`
prevents double destruction.

## Other resources

Objects that are not controls include Crystal-managed values and native
resources that need explicit cleanup. Creating one with `.new` or receiving it
from a method does not, by itself, determine which rule applies:

- A native resource used through `.open` is freed when the block ends.
- Whether a callback value can be retained depends on its type.
  `Table::Selection` and `FontDescriptor` can be kept; borrowed `Table::Value`
  and `Attribute` objects cannot be used after the callback.

Specific resource rules are:

- `Table::Model`: request destruction of all `Table` controls using the model
  before calling `model.free`. If native destruction is pending, the wrapper
  becomes unavailable immediately and the native model is freed after the last
  Table destruction completes.
- `Image`: call `free` when it is no longer needed. It can be freed after
  passing it to `ImageView#image=`, but must remain alive while a table or
  `Toolbar` uses it.
- `Toolbar`: detach it from its window before calling `free`.
- `Draw::Path`, `Draw::TextLayout`, and `AttributedString`: prefer `.open`
  where available so cleanup occurs when the block ends.
- `Table::Selection`: results from `table.selection`, callback values, and
  values created with `Table::Selection.new(rows)` are independent snapshots.
  They can be retained after a callback and do not need `free`.
- `FontDescriptor`: results from `FontButton#font` and callback values can be
  retained. Crystal manages them; do not call `free`.
- `OpenTypeFeatures`: Crystal manages the tags and values. It can be reused
  after passing it to `Attribute.new_features` and needs no `free`.
  `Attribute#features` returns an independent copy.
- `TM`: Crystal manages it. Outside Windows, `zone=` copies and retains its
  string. No `free` is needed.
- `Table::Value`: a value returned from `cell_value` is managed by libui-ng. A
  value passed to `set_cell_value` is valid only until that callback returns.
  Free a value you create but do not pass to libui-ng.
- `Attribute`: after `set_attribute`, the receiving `AttributedString` owns
  it. An attribute yielded by enumeration is valid only for that block.
- `OpenTypeFeatures` may be read recursively during enumeration, but tags
  cannot be added or removed. `AttributedString` may also be read recursively,
  but cannot be freed or structurally modified until enumeration finishes.
- A draw context is valid only during its draw callback.

Calling `destroy` or `free` makes the corresponding wrapper unavailable for
further use.
