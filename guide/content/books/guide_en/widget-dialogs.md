# Dialogs

[日本語](../guide_ja/widget-dialogs.html)

Window provides native message, error, file, folder, and save dialogs.

## Appearance

<div class="widget-screenshots">
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_msg_box-ubuntu.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_msg_box-ubuntu.png" alt="Dialogs on Ubuntu" loading="lazy"></a><figcaption>Ubuntu</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_msg_box-windows.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_msg_box-windows.png" alt="Dialogs on Windows" loading="lazy"></a><figcaption>Windows</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_msg_box-macos.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_msg_box-macos.png" alt="Dialogs on macOS" loading="lazy"></a><figcaption>macOS</figcaption></figure>
</div>

## Runnable example

{{% shell command="sh scripts/render-example basic_file_dialog" %}}

## Usage notes

- Call dialogs from their parent Window so the platform can keep modality and focus correct.
- <code>open_file</code>, <code>open_folder</code>, and <code>save_file</code> return <code>nil</code> when canceled.



[API reference](../../api/UIng/Window.html) · [Gallery source](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_file_dialog.cr)
