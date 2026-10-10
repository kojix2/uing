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

縦Boxにコントロールを並べる例です。

<pre><code class="crystal">
box = UIng::Box.new(:vertical, padded: true)
box.append(UIng::Label.new("Name"))
box.append(UIng::Entry.new)
box.append(UIng::Button.new("Save"))

window.child = box
</code></pre>

エディタに残りの高さを使わせるには`box.append(editor, stretchy: true)`とします。
複雑な配置はコンテナを入れ子にし、最外のコンテナをWindowの子にします（[Boxの実例](widget-box.html)、[コントロールギャラリー](https://github.com/kojix2/uing/tree/main/examples/gallery)）。

## 領域の配分と配置

「余った領域の配分」と「領域内での子の配置」は別の指定です。

| コンテナ | 領域の配分 | 領域内の配置 |
| --- | --- | --- |
| Box | `stretchy`で並べる方向に配分 | `true`の子はその方向に領域を満たす |
| Form | `stretchy`で高さを配分 | `true`の入力欄は縦に伸び、横は常に入力列を満たす |
| Grid | `hexpand`・`vexpand`で列・行に配分 | `halign`・`valign`で指定。`:fill`なら領域を満たす |

BoxとFormは配分と引き伸ばしをまとめて行い、個別の`fill`引数はありません。拡張と配置を分けるには[Grid](widget-grid.html)を使います。`padded`は子同士の間隔、`margined`は外周の余白で、伸縮とは独立です。

<a id="platform-differences"></a>

## プラットフォーム差

図は配置領域を示し、内部の部品の見た目とは異なる場合があります。macOSのSpinboxは入力欄と矢印の自然な高さを保って中央配置し、Windowsは入力欄を配置領域の高さに合わせます。最小サイズ、文字の位置、標準間隔もOSにより異なります。

## Widgetガイド

- ウィンドウ、メニュー、ダイアログ: [Window](widget-window.md)、
  [Toolbar](widget-toolbar.md)、[Menu](widget-menu.md)、[ダイアログ](widget-dialogs.md)
- 入力と選択: [Button](widget-button.md)、[Checkbox](widget-checkbox.md)、
  [Entry](widget-entry.md)、[Combobox](widget-combobox.md)、
  [EditableCombobox](widget-editable-combobox.md)、[RadioButtons](widget-radio-buttons.md)、
  [Slider](widget-slider.md)、[Spinbox](widget-spinbox.md)
- 専用コントロール: [ColorButton](widget-color-button.md)、
  [DateTimePicker](widget-date-time-picker.md)、[FontButton](widget-font-button.md)、
  [ImageView](widget-image-view.md)、[Label](widget-label.md)、
  [MultilineEntry](widget-multiline-entry.md)、[ProgressBar](widget-progress-bar.md)、
  [Separator](widget-separator.md)
- レイアウト: [Box](widget-box.md)、[Tab](widget-tab.md)、[Form](widget-form.md)、
  [Group](widget-group.md)、[Grid](widget-grid.md)
- データと描画: [Table](widget-table.md)、[Area](widget-area.md)
