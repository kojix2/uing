# ProgressBar

[English](../guide_en/widget-progress-bar.html)

ProgressBarは0から100までの進捗を表示します。

## 表示例

<div class="widget-screenshots">
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_progressbar-ubuntu.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_progressbar-ubuntu.png" alt="ProgressBar on Ubuntu" loading="lazy"></a><figcaption>Ubuntu</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_progressbar-windows.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_progressbar-windows.png" alt="ProgressBar on Windows" loading="lazy"></a><figcaption>Windows</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_progressbar-macos.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_progressbar-macos.png" alt="ProgressBar on macOS" loading="lazy"></a><figcaption>macOS</figcaption></figure>
</div>

## 実行例

{{% shell command="sh scripts/render-example basic_progressbar" %}}

## 使い方

- <code>-1</code>を設定すると不定進捗になります。
- 別スレッドの結果を反映するときは<code>UIng.queue_main</code>を使い、UIスレッド上で更新します。

[APIリファレンス](../../api/UIng/ProgressBar.html) · [Galleryソース](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_progressbar.cr)
