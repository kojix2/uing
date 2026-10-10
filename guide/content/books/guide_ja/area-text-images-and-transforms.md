# Areaのテキスト・画像・変換

[English](../guide_en/area-text-images-and-transforms.html)

## テキスト

Areaの文字列は`AttributedString`と`TextLayout`で描画します。文字列を作り、色やフォントなどの属性を設定してから、レイアウトをContextに描画します。`TextLayout.open`のブロック形式を使うと、一時的なレイアウトを安全に解放できます。

```crystal
string = UIng::Area::AttributedString.new("Hello, Area")
string.set_attribute(UIng::Area::Attribute.new_color(0.1, 0.1, 0.1, 1.0), 0, string.len)
font = UIng::FontDescriptor.new(family: "Sans", size: 14)
handler = UIng::Area::Handler.new

handler.draw do |_area, params|
  UIng::Area::Draw::TextLayout.open(
    string: string, default_font: font, width: 240,
    align: UIng::Area::Draw::TextAlign::Left
  ) do |layout|
    params.context.draw_text_layout(layout, 24, 24)
  end
end
```

長い文字列では、レイアウト幅と揃えを明示します。`string`と`font`はAreaを使う間保持し、終了時にそれぞれ`free`します。Contextと一時的なLayoutは`draw`の外へ持ち出しません。

## 画像と変換

`UIng::Image`を準備すると、`context.draw_image(image, x, y, width, height)`で指定サイズに描画できます。原寸で表示する場合は画像の幅と高さを渡します。画像は描画中だけ生成せず、読み込み後に保持して終了時に`free`します。

`Area::Draw::Matrix`は平行移動、拡大縮小、回転、せん断を扱います。ContextへMatrixを適用する範囲を小さくし、描画後に元の座標系へ戻す設計にすると、複数要素を扱いやすくなります。

```crystal
# draw内。imageは事前に作成したUIng::Imageです。
context = params.context
matrix = UIng::Area::Draw::Matrix.new.set_identity.translate(80, 40)
context.save
begin
  context.transform(matrix)
  context.draw_image(image, 0, 0, 100, 100)
ensure
  context.restore
end
```

- [basic_draw_text.cr](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_draw_text.cr): 属性付きテキスト
- [area_draw_image.cr](https://github.com/kojix2/uing/blob/main/examples/crimage/area_draw_image.cr): 画像の描画と拡大縮小
- [area_matrix.cr](https://github.com/kojix2/uing/blob/main/examples/gallery/area_matrix.cr): Matrixによる変換
