# Areaの画像

[English](../guide_en/area-images.html)

`UIng::Image`を作成して保持し、`draw`内で`context.draw_image`を呼びます。画像を描画のたびに作り直しません。

## 画像の作成と描画

| API | 用途 |
| --- | --- |
| `Image.new(width, height)` | 論理サイズを指定して空の画像を作る |
| `image.size` / `image.width` / `image.height` | ポイント単位の論理サイズを取得する |
| `image.append(pixels, pixel_width, pixel_height, byte_stride)` | premultiplied RGBAピクセルを追加する |
| `draw_image(image, x, y, width, height)` | 指定した矩形へ描画する |
| `image.free` | 不要になった画像を解放する |

`draw_image`の`width`と`height`は有限かつ正の値でなければなりません。渡した値が表示サイズになるため、縦横比は呼び出し側で保ちます。

```crystal
handler.draw do |_area, params|
  params.context.draw_image(image, 24, 24, 128, 128)
end
```

## 構築ブロック

`Image.new`では、ブロック内で画像の表現を追加できます。

```crystal
image = UIng::Image.new(16, 16) do
  append(pixels_1x, 16, 16, 64)
  append(pixels_2x, 32, 32, 128)
end
```

`ImageBuffer.new`も、固定解像度のバッファを作成して初期ピクセルを設定するブロックを受け取れます。CrImage画像を渡す`ImageBuffer.new(source)`でも同じ形式が使えます。

```crystal
buffer = UIng::ImageBuffer.new(1, 1) do
  update(Bytes[255, 0, 0, 255])
end
```

どちらも`|image|`や`|buffer|`で生成したオブジェクトを受け取れます。戻り値はブロックの結果によらずそのオブジェクトです。設定ブロックが例外終了すると解放します。正常終了後は呼び出し側が所有し、不要になったら`free`します。`ImageBuffer.open`は通常の引数渡しで、ブロック終了時に解放する形式です。

## ファイルから読み込む

`require "uing/crimage"`を使うと、ファイルまたはCrImageの画像から`UIng::Image`を作れます。

```crystal
require "uing/crimage"

image = UIng::Image.from_file("logo.png")

window.on_closing do
  image.free
  UIng.quit
  true
end
```

| API | 用途 |
| --- | --- |
| `UIng::Image.from_file(path)` | ファイルを読み込み、ネイティブ画像へ変換する |
| `source.to_uing_image` | `CrImage::Image`をネイティブ画像へ変換する |
| `image.append(source)` | 同じ画像へCrImageの表現を追加する |

高解像度の表現を追加する場合は、同じ`Image`に`append`します。作成した`Image`は呼び出し側が所有し、不要になった時点で`free`します。

[area_draw_image.cr](https://github.com/kojix2/uing/blob/main/examples/crimage/area_draw_image.cr)は画像の描画と拡大縮小の例です。
