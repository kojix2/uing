# Toolbar

[日本語](../guide_ja/widget-toolbar.html)

Toolbar adds native command buttons to a Window. It supports regular buttons, toggle buttons, separators, icons, tooltips, and several display modes.

Toolbar is an experimental feature specific to `kojix2/libui-ng` and may change.

## Appearance

<div class="widget-screenshots">
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_toolbar-ubuntu.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_toolbar-ubuntu.png" alt="Toolbar on Ubuntu" loading="lazy"></a><figcaption>Ubuntu</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_toolbar-windows.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_toolbar-windows.png" alt="Toolbar on Windows" loading="lazy"></a><figcaption>Windows</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_toolbar-macos.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_toolbar-macos.png" alt="Toolbar on macOS" loading="lazy"></a><figcaption>macOS</figcaption></figure>
</div>

## Runnable example

{{% shell command="sh scripts/render-example basic_toolbar" %}}

## Usage notes

Build items with `Toolbar.new`, then attach the Toolbar returned by the `window.toolbar` block. The Window block keeps its outer receiver.

```crystal
window.toolbar do
  UIng::Toolbar.new do
    append_button("Open") do |item|
      item.tooltip = "Open document"
      on_clicked { |_clicked| puts "Open clicked" }
    end
    append_toggle_button("Pinned") do |item|
      item.checked = true
    end
  end
end
```

Item configuration blocks allow direct calls to ToolbarItem methods. Use `|item|` for property assignments. `Toolbar.new` returns the Toolbar; `append_button` and `append_toggle_button` return the ToolbarItem. The same blocks are supported when passing CrImage icons.

If a `Toolbar.new` block raises, the Toolbar is detached if necessary, the Toolbar and its items are freed, and the original exception is re-raised. If only an item configuration block on an existing Toolbar raises, the item remains appended.

- Add every item before attaching the Toolbar to a Window for the first time. After its first attachment, items cannot be added even if the Toolbar is detached.
- <code>display_mode</code> can be changed after attachment. Existing items, click callbacks, enabled states, and toggle checked states are preserved when the mode changes.
- A Toolbar can be attached to only one Window at a time. Destroying that Window also frees its attached Toolbar. Assign <code>nil</code> to <code>window.toolbar</code> before destroying the Window if you want to reuse the Toolbar. A detached Toolbar still needs <code>free</code>.
- Toolbar items copy their icons, including icons set later with <code>icon=</code>. You may free an Image immediately after passing it to a Toolbar; the Toolbar frees its own copies. Assign <code>nil</code> before calling <code>toolbar.free</code> on an attached Toolbar.
- Image retains its source pixel data to support copying, so large images use additional memory.
- <code>checked?</code> and <code>checked=</code> are available only on items created by <code>append_toggle_button</code>.
- On macOS, <code>IconAndTextHorizontal</code> is displayed vertically.

Change the display mode of an attached Toolbar as follows. The runnable Gallery example also lets you switch modes using a combobox.

```crystal
window.toolbar = toolbar
toolbar.display_mode = UIng::Toolbar::DisplayMode::TextOnly
toolbar.display_mode = UIng::Toolbar::DisplayMode::IconOnly
toolbar.display_mode = UIng::Toolbar::DisplayMode::IconAndTextVertical
```

[Toolbar API](../../api/UIng/Toolbar.html) · [ToolbarItem API](../../api/UIng/ToolbarItem.html) · [Gallery source](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_toolbar.cr)
