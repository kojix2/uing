# Tab

[English](../guide_en/widget-tab.html)

Tabはコントロールを名前付きの複数ページに整理します。

## 表示例

<div class="widget-screenshots">
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_tab-ubuntu.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_tab-ubuntu.png" alt="Tab on Ubuntu" loading="lazy"></a><figcaption>Ubuntu</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_tab-windows.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_tab-windows.png" alt="Tab on Windows" loading="lazy"></a><figcaption>Windows</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_tab-macos.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_tab-macos.png" alt="Tab on macOS" loading="lazy"></a><figcaption>macOS</figcaption></figure>
</div>

## 実行例

{{% shell command="sh scripts/render-example basic_tab" %}}

## 使い方

`append`または`insert_at`でページを追加します。各ページが持つ子は1つで、複数のコントロールはBoxやFormにまとめます。選択中のページだけが表示されます。

![selectedが0ならGeneralのBoxを、1ならDetailsのFormを表示する](../../images/tab-pages.svg)

```crystal
tab = UIng::Tab.new
tab.append("General", UIng::Box.new(:vertical), margined: true)
tab.append("Details", UIng::Form.new, margined: true)
tab.selected = 1
```

`selected`は0始まりのページ番号です。変更は`on_selected`で受け取ります。余白はページごとに`margined: true`で指定し、追加後は`set_margined(index, true)`で変更できます。

[APIリファレンス](../../api/UIng/Tab.html) · [Galleryソース](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_tab.cr)
