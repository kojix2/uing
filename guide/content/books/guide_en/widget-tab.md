# Tab

[日本語](../guide_ja/widget-tab.html)

Tab organizes controls into named pages.

## Appearance

<div class="widget-screenshots">
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_tab-ubuntu.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_tab-ubuntu.png" alt="Tab on Ubuntu" loading="lazy"></a><figcaption>Ubuntu</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_tab-windows.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_tab-windows.png" alt="Tab on Windows" loading="lazy"></a><figcaption>Windows</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_tab-macos.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_tab-macos.png" alt="Tab on macOS" loading="lazy"></a><figcaption>macOS</figcaption></figure>
</div>

## Runnable example

{{% shell command="sh scripts/render-example basic_tab" %}}

## Usage notes

Add pages with `append` or `insert_at`. Each page holds one child; use a Box or Form for multiple controls. Only the selected page is shown.

![With selected set to 0, General shows its Box; with 1, Details shows its Form.](../../images/tab-pages.svg)

```crystal
tab = UIng::Tab.new
tab.append("General", UIng::Box.new(:vertical), margined: true)
tab.append("Details", UIng::Form.new, margined: true)
tab.selected = 1
```

`append` and `insert_at` also accept a block that returns the page's child Control. The insertion `index` is zero-based; using the current page count appends at the end.

```crystal
tab.insert_at("Advanced", index: 1, margined: true) do
  UIng::Box.new(:vertical, padded: true) do
    append { UIng::Label.new("Advanced settings") }
  end
end
```

`selected` is a zero-based page index; `on_selected` reports changes. Set margins per page with `margined: true`, or change them later with `set_margined(index, true)`.

[API reference](../../api/UIng/Tab.html) · [Gallery source](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_tab.cr)
