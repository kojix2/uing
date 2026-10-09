# DateTimePicker

[English](../guide_en/widget-date-time-picker.html)

DateTimePickerは日付、時刻、日付と時刻のネイティブ入力を提供します。

## 表示例

<div class="widget-screenshots">
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_date_time_picker-ubuntu.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_date_time_picker-ubuntu.png" alt="DateTimePicker on Ubuntu" loading="lazy"></a><figcaption>Ubuntu</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_date_time_picker-windows.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_date_time_picker-windows.png" alt="DateTimePicker on Windows" loading="lazy"></a><figcaption>Windows</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_date_time_picker-macos.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_date_time_picker-macos.png" alt="DateTimePicker on macOS" loading="lazy"></a><figcaption>macOS</figcaption></figure>
</div>

## 実行例

{{% shell command="sh scripts/render-example basic_date_time_picker" %}}

## 使い方

- <code>:date</code>、<code>:time</code>、<code>:date_time</code>を指定して作成します。型付きの<code>UIng::DateTimePicker::Type</code>も使用できます。
- 値はローカルのwall-clockフィールドとして扱われ、元のタイムゾーンや瞬間は保持されません。

[APIリファレンス](../../api/UIng/DateTimePicker.html) · [Galleryソース](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_date_time_picker.cr)
