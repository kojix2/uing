# Form

[English](../guide_en/widget-form.html)

Formはラベルとコントロールをネイティブなフォーム行として整列します。

## 表示例

<div class="widget-screenshots">
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_form-ubuntu.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_form-ubuntu.png" alt="Form on Ubuntu" loading="lazy"></a><figcaption>Ubuntu</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_form-windows.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_form-windows.png" alt="Form on Windows" loading="lazy"></a><figcaption>Windows</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_form-macos.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_form-macos.png" alt="Form on macOS" loading="lazy"></a><figcaption>macOS</figcaption></figure>
</div>

## 実行例

{{% shell command="sh scripts/render-example basic_form" %}}

## 使い方

`append`でラベルとコントロールを1行ずつ追加します。`stretchy: true`は入力欄を余った高さまで広げ、既定の`false`は必要な高さを保ちます。横方向はどちらも入力列の幅を満たします。

![Formはラベルと入力欄を列に揃え、Notesの行だけを縦に伸ばす](../../images/form-layout.svg)

```crystal
form = UIng::Form.new(padded: true)
form.append("Name", UIng::Entry.new)
form.append("Notes", UIng::MultilineEntry.new, stretchy: true)
```

`padded: true`で行・列の間隔を空けます。縦Box内でFormを縦に広げるには、Boxの`append`にも`stretchy: true`が必要です。

ラベルはWindowsで左寄せ、Linux・macOSで右寄せです（[プラットフォーム差](controls-and-layout.html#platform-differences)）。

[APIリファレンス](../../api/UIng/Form.html) · [Galleryソース](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_form.cr)
