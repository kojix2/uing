# Box

[English](../guide_en/widget-box.html)

Boxは子コントロールを水平または垂直に並べます。

## 表示例

<div class="widget-screenshots">
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_box_vertical-ubuntu.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_box_vertical-ubuntu.png" alt="Box on Ubuntu" loading="lazy"></a><figcaption>Ubuntu</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_box_vertical-windows.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_box_vertical-windows.png" alt="Box on Windows" loading="lazy"></a><figcaption>Windows</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_box_vertical-macos.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_box_vertical-macos.png" alt="Box on macOS" loading="lazy"></a><figcaption>macOS</figcaption></figure>
</div>

## 実行例

{{% shell command="sh scripts/render-example basic_box_vertical" %}}

## 並べる方向と伸縮

`:horizontal`は横並び、`:vertical`は縦並びです。子は`append`した順に配置されます。

`append`の`stretchy`は、横Boxでは幅、縦Boxでは高さの配分を指定します。

| 指定 | 並べる方向のサイズ |
| --- | --- |
| `stretchy: false`（既定） | 内容に必要なサイズを保ち、余った領域を受け取らない |
| `stretchy: true` | 伸縮しない子と間隔の領域を除き、残りを使う |

`true`が複数なら、それらの幅（縦Boxなら高さ）は等しくなります。重みの指定はありません。すべて`false`なら左（縦Boxなら上）に詰め、余りは末尾に残ります。最小サイズは子の必要サイズに従います。

直交する方向は基本的にBoxを満たすため、`false`でも縦Boxの子は横に広がります。ただし、横BoxのLabelは自然な高さで上下中央に配置されます。

## 子同士の間隔と外周の余白

`padded: true`は隣り合う子の間に標準間隔を入れます。既定値は`false`です。外周の余白はWindowやGroupの`margined`で設定します。

```text
Window (margined: true)
+---------------------------------------+
|                margin                 |
|  +---------------------------------+  |
|  | [A]  gap  [B]  gap  [C]          |  |  Box (padded: true)
|  +---------------------------------+  |
|                margin                 |
+---------------------------------------+
```

間隔の寸法はOSや表示設定に従い、ピクセル数は指定できません。`box.padded = true`で作成後も変更できます。入れ子ではBoxごとに設定します。

## 入れ子で組み立てる

検索行、エディタ、状態表示を組み合わせます。`UIng.init`後、作成済みの`window`に配置してください。

```crystal
search = UIng::Box.new(:horizontal, padded: true)
search.append(UIng::Label.new("検索"))
search.append(UIng::Entry.new, stretchy: true) # 横方向に伸びる
search.append(UIng::Button.new("検索"))

editor = UIng::MultilineEntry.new
status = UIng::Label.new("準備完了")

body = UIng::Box.new(:vertical, padded: true)
body.append(search)                # 検索行の高さは必要な分だけ
body.append(editor, stretchy: true) # 残りの高さを使う
body.append(status)

window.margined = true
window.child = body
```

横に広げると検索欄とエディタが、縦に広げるとエディタが伸びます。検索行の高さと状態表示の高さは保たれます。

`stretchy`は親から子への割り当てです。`body`を別の縦Boxに入れて縦に伸ばす場合は、その`append`にも`stretchy: true`を指定します。

[水平Boxの例](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_box_horizontal.cr)も参照してください。

[APIリファレンス](../../api/UIng/Box.html) · [Galleryソース](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_box_vertical.cr)
