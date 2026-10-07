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

- Add every item and set <code>display_mode</code> before attaching the Toolbar to a Window. Neither can be changed after its first attachment.
- A Toolbar can be attached to only one Window at a time. Assign <code>nil</code> to <code>window.toolbar</code> before calling <code>toolbar.free</code>.
- Keep an Image alive while the Toolbar is using it, then free the Image after freeing the Toolbar.
- <code>checked?</code> and <code>checked=</code> are available only on items created by <code>append_toggle_button</code>.
- On macOS, <code>IconAndTextHorizontal</code> is displayed vertically.

[Toolbar API](../../api/UIng/Toolbar.html) · [ToolbarItem API](../../api/UIng/ToolbarItem.html) · [Gallery source](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_toolbar.cr)
