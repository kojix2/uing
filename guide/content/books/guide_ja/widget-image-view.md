# ImageView

[English](../guide_en/widget-image-view.html)

ImageViewは、UIngのImageをOS標準の画像ビューへ表示します。UIngは生の画素を受け取り、画像デコーダーには依存しません。画像・色の便利メソッドを使う場合は、アプリケーションの`shard.yml`にCrImageを追加します。

```yaml
dependencies:
  uing:
    github: kojix2/uing
  crimage:
    github: naqvis/crimage
```

```crystal
require "uing/crimage"

source = CrImage.read("photo.png")
view = UIng::ImageView.new(source, :fit)
view.image = CrImage.read("next.png")

# Area、Table、Toolbarで使う画像は、利用が終わるまで保持します。
image = UIng::Image.from_crimage(source)
# ... image を使用 ...
image.free
```

## 実行例

{{% shell command="sh scripts/render-example basic_image_view" %}}

## 使い方

- <code>ContentMode::Fit</code>はビューに収まるよう画像を拡大縮小し、<code>ContentMode::Center</code>は画像を本来のサイズで中央に表示します。
- <code>image=</code>で別のImageを設定できます。<code>nil</code>を代入すると表示を消去します。
- ImageViewはネイティブ画像を内部でコピーまたは保持します。そのため、構築または代入の直後に元のImageを解放できます。
- `require "uing"`だけならCrImageは不要です。`require "uing/crimage"`で便利メソッドが追加され、アプリ側のCrImage依存が必要になります。
- `UIng::Image.from_file(path)`はファイル内容から形式を判定します。現在のCrImageの`CrImage.read(path)`は拡張子で形式を選びます。
- `UIng::Image.from_crimage`、`CrImage::Image#to_uing_image`、`UIng::Image#append(CrImage::Image)`は各種CrImage画像を受け取り、premultiplied RGBAへ変換します。原点が0でない画像やサブ画像にも対応します。
- `ImageView`は設定時に作る一時的なUIng画像を解放します。`from_crimage`、`from_file`、`to_uing_image`が返す画像は、利用先の使用が終わった後に呼び出し側が解放してください。
- 同じ拡張で`ColorButton#set_color`、単色Brush、グラデーション停止点、文字属性、Tableの色値へCrImageの色を渡せます。半透明のUI色には`CrImage::Color::NRGBA`を使います。現在のCrImageの`Color.parse`は半透明RGBAを正しくpremultiplyしません。

[ImageView API](../../api/UIng/ImageView.html) · [Image API](../../api/UIng/Image.html) · [Galleryソース](https://github.com/kojix2/uing/blob/main/examples/crimage/basic_image_view.cr)
