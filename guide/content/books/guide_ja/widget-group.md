# Group

[English](../guide_en/widget-group.html)

Groupは1つの子コントロールをタイトル付きの枠内に配置します。

## 表示例

<div class="widget-screenshots">
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_group-ubuntu.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_group-ubuntu.png" alt="Group on Ubuntu" loading="lazy"></a><figcaption>Ubuntu</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_group-windows.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_group-windows.png" alt="Group on Windows" loading="lazy"></a><figcaption>Windows</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_group-macos.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_group-macos.png" alt="Group on macOS" loading="lazy"></a><figcaption>macOS</figcaption></figure>
</div>

## 実行例

{{% shell command="sh scripts/render-example basic_group" %}}

## 使い方

Groupが直接持てる子は1つです。複数のコントロールはBox、Form、Gridにまとめて`child`に指定します。

![Groupの唯一の子としてBoxを配置し、その中にA・Bを並べる。Groupの余白とBoxの間隔は独立する](../../images/group-child.svg)

```crystal
box = UIng::Box.new(:vertical, padded: true)
box.append(UIng::Checkbox.new("A"))
box.append(UIng::Checkbox.new("B"))
group = UIng::Group.new("Settings", margined: true)
group.child = box
```

`margined: true`は枠と子の間の余白、Boxの`padded: true`は子同士の間隔を設定します。

[APIリファレンス](../../api/UIng/Group.html) · [Galleryソース](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_group.cr)
