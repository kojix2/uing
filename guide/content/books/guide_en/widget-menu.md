# Menu

[日本語](../guide_ja/widget-menu.html)

Menu creates application menu bars and native standard menu items.

## Appearance

<div class="widget-screenshots">
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_menu-ubuntu.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_menu-ubuntu.png" alt="Menu on Ubuntu" loading="lazy"></a><figcaption>Ubuntu</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_menu-windows.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_menu-windows.png" alt="Menu on Windows" loading="lazy"></a><figcaption>Windows</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_menu-macos.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_menu-macos.png" alt="Menu on macOS" loading="lazy"></a><figcaption>macOS</figcaption></figure>
</div>

## Runnable example

{{% shell command="sh scripts/render-example basic_menu" %}}

## Usage notes

- Menu items come in the following forms:

  | Type | Factory method | Purpose |
  | --- | --- | --- |
  | Regular item | <code>append_item(name)</code> | Runs a command. |
  | Check item | <code>append_check_item(name, checked:)</code> | Represents an on/off state. Read or change it with <code>checked?</code> and <code>checked=</code>. |
  | Preferences item | <code>append_preferences_item</code> | Opens application preferences. |
  | About item | <code>append_about_item</code> | Shows application information. |
  | Quit item | <code>append_quit_item</code> | Exits the application. Configure shutdown through <code>UIng.on_should_quit</code>. |
  | Separator | <code>append_separator</code> | Visually separates related groups of items. |

- Finalize all menus before creating the first Window, and set <code>menubar: true</code>.
- Menu callbacks receive an optional Window because some platform-level actions may not have one.
- <code>Preferences</code>, <code>About</code>, and <code>Quit</code> are standard items that follow OS menu conventions. Their label, placement, and surrounding separators vary by OS, so they may not appear in the Menu or order where you add them.
- You can add only one <code>append_preferences_item</code>, <code>append_about_item</code>, and <code>append_quit_item</code> item per application.



[API reference](../../api/UIng/Menu.html) · [Gallery source](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_menu.cr)
