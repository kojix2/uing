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

Here is the control gallery in action. The same code renders with the native
look of each platform:

<div class="widget-screenshots">
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/control_gallery-ubuntu.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/control_gallery-ubuntu.png" alt="Control gallery on Ubuntu" loading="lazy"></a><figcaption>Ubuntu</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/control_gallery-windows.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/control_gallery-windows.png" alt="Control gallery on Windows" loading="lazy"></a><figcaption>Windows</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/control_gallery-macos.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/control_gallery-macos.png" alt="Control gallery on macOS" loading="lazy"></a><figcaption>macOS</figcaption></figure>
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
