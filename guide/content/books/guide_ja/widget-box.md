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

子は`append`した順に並び、`stretchy`は子ごとに指定します。

| Boxの向き | `stretchy: false`（既定） | `stretchy: true` | 直交する方向 |
| --- | --- | --- | --- |
| 横 `:horizontal` | 必要な幅を保つ | 残りの幅を受け取る | 高さは原則Boxに合わせる |
| 縦 `:vertical` | 必要な高さを保つ | 残りの高さを受け取る | 幅は原則Boxに合わせる |

`true`が複数なら、それらの幅（縦Boxなら高さ）は等しくなります。重みの指定はありません。すべて`false`なら左（縦Boxなら上）に詰め、余りは末尾に残ります。最小サイズは子の必要サイズに従います。

![横BoxでBだけを伸縮させる場合と、B・Cに等しい幅を割り当てる場合](../../images/box-stretchy.svg)

横BoxのLabelは自然な高さで上下中央に配置されます。部品内部の見た目には[プラットフォーム差](controls-and-layout.html#platform-differences)があります。拡張と中央寄せなどを別々に指定するには[Grid](widget-grid.html)を使います。

## 子同士の間隔と外周の余白

`padded: true`は子同士の間隔、WindowやGroupの`margined`は外周の余白を設定します。`padded`の既定値は`false`です。

![WindowのmarginedはBoxの外周に余白を、Boxのpaddedは子A・B・Cの間に間隔を設ける](../../images/box-spacing.svg)

間隔はOSや表示設定に従い、ピクセル数は指定できません。`box.padded = true`で変更でき、入れ子ではBoxごとに設定します。

## 入れ子で組み立てる

`UIng.init`後、作成済みの`window`に配置する例です。

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

`body`を別の縦Boxに入れて縦に伸ばす場合は、その`append`にも`stretchy: true`が必要です。

[水平Boxの例](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_box_horizontal.cr)も参照してください。

[APIリファレンス](../../api/UIng/Box.html) · [Galleryソース](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_box_vertical.cr)
