# Introduction

[日本語](../guide_ja/introduction.html)

UIng is a Crystal binding for
[libui-ng](https://github.com/kojix2/libui-ng), a portable library for native
desktop interfaces. It gives Crystal applications access to windows, buttons,
text fields, menus, tables, drawing areas, and other standard controls without
shipping a browser engine or a custom widget toolkit.

The same application source can target:

- Linux and other Unix-like systems through GTK 3
- macOS through AppKit
- Windows through Win32, Direct2D, and DirectWrite

The [basic window example](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_window.cr)
shows how the same code takes on each platform's native look:

<div class="widget-screenshots">
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_window-ubuntu.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_window-ubuntu.png" alt="Basic window on Ubuntu" loading="lazy"></a><figcaption>Ubuntu</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_window-windows.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_window-windows.png" alt="Basic window on Windows" loading="lazy"></a><figcaption>Windows</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_window-macos.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_window-macos.png" alt="Basic window on macOS" loading="lazy"></a><figcaption>macOS</figcaption></figure>
</div>

This guide focuses on the small set of concepts needed to create an
application. Interfaces can be written with the regular API or the
block-based DSL; see [Coding Styles](coding-styles.md) for details.
For the complete list of types and methods, use the
[API Reference](../../api/).

## Project focus

UIng aims to provide a small, sustainable foundation for simple native GUIs.
Its priority is to remain stable and maintainable over the long term rather
than grow into a full-featured GUI framework.

## Limitations

- Layout is intentionally based on native containers. Controls cannot be
  positioned with arbitrary pixel coordinates, which helps preserve a native
  appearance across platforms.
- Table columns cannot be removed after they have been added.
