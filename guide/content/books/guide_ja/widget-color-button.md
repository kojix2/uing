# ColorButton

[English](../guide_en/widget-color-button.html)

ColorButtonはOS標準のカラーピッカーを開き、RGBA色を保持します。

## 実行例

{{% shell command="sh scripts/render-example basic_color_button" %}}

## 使い方

- RGBA成分は<code>0.0</code>から<code>1.0</code>までの浮動小数点数です。
- <code>on_changed</code>には赤・緑・青・アルファ値が渡されます。
- アプリ側にCrImageを追加して`require "uing/crimage"`すると、`color =`と`set_color`へ`CrImage::Color::Color`を渡せます。`color`の読み取りは引き続き数値RGBAのタプルを返し、`color_crimage`は`CrImage::Color::NRGBA`を返します。半透明色には`NRGBA`を使ってください。現在の`Color.parse`は半透明`RGBA`の色成分をpremultiplyしません。

```crystal
button.color = CrImage::Color::NRGBA.new(255, 0, 0, 128)
selected = button.color_crimage
```

[APIリファレンス](../../api/UIng/ColorButton.html) · [Galleryソース](https://github.com/kojix2/uing/blob/main/examples/crimage/basic_color_button.cr)
