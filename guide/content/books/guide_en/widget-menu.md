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

`append_item`, `append_check_item`, `append_preferences_item`, `append_about_item`, and `append_quit_item` also accept a block to configure the new MenuItem. Inside the block, you can call MenuItem methods directly or receive the item as `|item|`. These methods return the MenuItem regardless of the block's result.

```crystal
UIng::Menu.new("File") do
  append_item("Open") do
    set_shortcut('O', UIng::Modifiers::Primary)
    on_clicked { |window| window.try &.open_file }
  end
end
```

For check items, use `append_check_item("Labels", checked: true) do ... end` to set the initial state. Quit items still reject `on_clicked` inside configuration blocks; configure shutdown with `UIng.on_should_quit`.

- Finalize all menus before creating the first Window, and set <code>menubar: true</code>.
- Assign a shortcut before creating the first Window with `item.set_shortcut('O', UIng::Modifiers::Primary)`. `Primary` means Command on macOS and Control on Windows/Linux. Use `item.clear_shortcut` to remove it.
- Shortcut keys are ASCII letters or digits, `UIng::ExtKey::F1`–`F12`, `Delete`, or arrow keys. F1–F12 may be unmodified; other keys need `Primary`, `Ctrl`, or `Alt`. `Shift` may be added. `Super`, `Primary | Ctrl`, and duplicate shortcuts are invalid.
- Menu callbacks receive an optional Window because some platform-level actions may not have one.
- `item.clear_on_clicked` is the same as `item.on_clicked(nil)`: it releases the click callback while keeping the item usable. Neither call removes the item from its menu. Quit items use `UIng.clear_on_should_quit` instead.
- <code>Preferences</code>, <code>About</code>, and <code>Quit</code> are standard items that follow OS menu conventions. Their label, placement, and surrounding separators vary by OS, so they may not appear in the Menu or order where you add them.
- You can add only one <code>append_preferences_item</code>, <code>append_about_item</code>, and <code>append_quit_item</code> item per application.



[API reference](../../api/UIng/Menu.html) · [Gallery source](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_menu.cr)
