# Dialogs

[日本語](../guide_ja/widget-dialogs.html)

Window provides native message, error, file, folder, and save dialogs.

## Appearance

<div class="widget-screenshots">
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_file_dialog-ubuntu.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_file_dialog-ubuntu.png" alt="File dialog on Ubuntu" loading="lazy"></a><figcaption>Ubuntu</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_file_dialog-windows.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_file_dialog-windows.png" alt="File dialog on Windows" loading="lazy"></a><figcaption>Windows</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_file_dialog-macos.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_file_dialog-macos.png" alt="File dialog on macOS" loading="lazy"></a><figcaption>macOS</figcaption></figure>
</div>

## Runnable example

{{% shell command="sh scripts/render-example basic_file_dialog" %}}

## Types

### Messages

| Method | Purpose | Return value |
| --- | --- | --- |
| <code>msg_box(title, description)</code> | Shows information or a notice. | <code>Nil</code> |
| <code>msg_box_error(title, description)</code> | Shows an error. | <code>Nil</code> |

### Files and folders

| Method | Purpose | Return value |
| --- | --- | --- |
| <code>open_file</code> | Selects a file to open. | The selected path, or <code>nil</code> if canceled. |
| <code>open_files</code> | Selects one or more files. | An array of paths, or <code>nil</code> if canceled. |
| <code>save_file</code> | Selects a file to save. | The selected path, or <code>nil</code> if canceled. |
| <code>open_folder</code> | Selects a folder to open. | The selected path, or <code>nil</code> if canceled. |
| <code>open_folders</code> | Selects one or more folders. | An array of paths, or <code>nil</code> if canceled. |

## Usage notes

- Call dialogs from their parent Window so the platform can keep modality and focus correct.
- File and folder dialogs return <code>nil</code> when canceled or if the dialog fails. The multiple-selection methods return one or more paths on success; selection order is unspecified.
- Appearance and detailed behavior follow the OS-native dialog.



[API reference](../../api/UIng/Window.html) · [Gallery source](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_file_dialog.cr)
