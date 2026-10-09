# DateTimePicker

[日本語](../guide_ja/widget-date-time-picker.html)

DateTimePicker provides native date, time, and combined date-time editors.

## Appearance

<div class="widget-screenshots">
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_date_time_picker-ubuntu.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_date_time_picker-ubuntu.png" alt="DateTimePicker on Ubuntu" loading="lazy"></a><figcaption>Ubuntu</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_date_time_picker-windows.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_date_time_picker-windows.png" alt="DateTimePicker on Windows" loading="lazy"></a><figcaption>Windows</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_date_time_picker-macos.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_date_time_picker-macos.png" alt="DateTimePicker on macOS" loading="lazy"></a><figcaption>macOS</figcaption></figure>
</div>

## Runnable example

{{% shell command="sh scripts/render-example basic_date_time_picker" %}}

## Usage notes

- Construct it with <code>:date</code>, <code>:time</code>, or <code>:date_time</code>. The typed <code>UIng::DateTimePicker::Type</code> values are also accepted.
- Values are local wall-clock fields; assigning a <code>Time</code> does not preserve its original zone or instant.

[API reference](../../api/UIng/DateTimePicker.html) · [Gallery source](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_date_time_picker.cr)
