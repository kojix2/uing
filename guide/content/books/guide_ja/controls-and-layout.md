# コントロールとレイアウト

[English](../guide_en/controls-and-layout.html)

UIngは、テキストの表示、入力、値の選択、進捗表示、メニュー、表形式のデータなどに使う
ネイティブコントロールを提供します。最初によく使うものには`Label`、`Button`、`Entry`、
`Checkbox`、`Combobox`、`Slider`、`ProgressBar`があります。

## コンテナ

1つのウィンドウが持てる子は1つです。複数のコントロールを配置するときはコンテナを
使用します。

- `Box`は子を横方向または縦方向に並べます。
- `Form`はラベルと入力コントロールを揃えます。
- `Grid`はコントロールを行と列に配置します。
- `Group`は1つの子をタイトル付きの枠内に配置します。
- `Tab`はコントロールを複数のページに整理します。

次の縦方向のBoxはコントロールをまとめ、ネイティブな間隔を追加します。

<pre><code class="crystal">
box = UIng::Box.new(:vertical, padded: true)
box.append(UIng::Label.new("Name"))
box.append(UIng::Entry.new)
box.append(UIng::Button.new("Save"))

window.child = box
</code></pre>

`Box#append`の省略可能な`stretchy`引数は、子が残りの領域を使用するかどうかを
制御します。

<pre><code class="crystal">
box.append(editor, stretchy: true)
</code></pre>

まず小さなコンテナを作り、必要に応じて入れ子にして、一番外側のコンテナを
ウィンドウに割り当てます。各コントロールとレイアウトの例は
[コントロールギャラリー](https://github.com/kojix2/uing/tree/main/examples/gallery)を
参照してください。

## Widgetガイド

- ウィンドウ、メニュー、ダイアログ: [Window](widget-window.md)、[Menu](widget-menu.md)、
  [ダイアログ](widget-dialogs.md)
- 入力と選択: [Button](widget-button.md)、[Checkbox](widget-checkbox.md)、
  [Entry](widget-entry.md)、[Combobox](widget-combobox.md)、
  [EditableCombobox](widget-editable-combobox.md)、[RadioButtons](widget-radio-buttons.md)、
  [Slider](widget-slider.md)、[Spinbox](widget-spinbox.md)
- 専用コントロール: [ColorButton](widget-color-button.md)、
  [DateTimePicker](widget-date-time-picker.md)、[FontButton](widget-font-button.md)、
  [Label](widget-label.md)、[MultilineEntry](widget-multiline-entry.md)、
  [ProgressBar](widget-progress-bar.md)、[Separator](widget-separator.md)
- レイアウト: [Box](widget-box.md)、[Tab](widget-tab.md)、[Form](widget-form.md)、
  [Group](widget-group.md)、[Grid](widget-grid.md)
- データと描画: [Table](widget-table.md)、[Area](widget-area.md)
