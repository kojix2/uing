# Button

[日本語](../guide_ja/widget-button.html)

Button performs an action when the user clicks it.

## Appearance

<div class="widget-screenshots">
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_button-ubuntu.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_button-ubuntu.png" alt="Button on Ubuntu" loading="lazy"></a><figcaption>Ubuntu</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_button-windows.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_button-windows.png" alt="Button on Windows" loading="lazy"></a><figcaption>Windows</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_button-macos.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_button-macos.png" alt="Button on macOS" loading="lazy"></a><figcaption>macOS</figcaption></figure>
</div>

## Runnable example

{{% shell command="sh scripts/render-example basic_button" %}}

## Usage notes

- Handle clicks with <code>on_clicked</code>.
- The inherited <code>tooltip</code>, <code>enable</code>, and <code>disable</code> operations are available.

[API reference](../../api/UIng/Button.html) · [Gallery source](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_button.cr)
