# ProgressBar

[日本語](../guide_ja/widget-progress-bar.html)

ProgressBar displays completion from 0 through 100.

## Appearance

<div class="widget-screenshots">
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_progressbar-ubuntu.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_progressbar-ubuntu.png" alt="ProgressBar on Ubuntu" loading="lazy"></a><figcaption>Ubuntu</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_progressbar-windows.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_progressbar-windows.png" alt="ProgressBar on Windows" loading="lazy"></a><figcaption>Windows</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_progressbar-macos.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_progressbar-macos.png" alt="ProgressBar on macOS" loading="lazy"></a><figcaption>macOS</figcaption></figure>
</div>

## Runnable example

{{% shell command="sh scripts/render-example basic_progressbar" %}}

## Usage notes

- Assign <code>-1</code> to show indeterminate progress.
- Update widgets only from the UI thread; use <code>UIng.queue_main</code> when work finishes elsewhere.

[API reference](../../api/UIng/ProgressBar.html) · [Gallery source](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_progressbar.cr)
