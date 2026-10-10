# Area

[English](../guide_en/widget-area.html)

AreaはArea::Handlerで描画と入力を処理するカスタム描画領域です。

## 表示例

<div class="widget-screenshots">
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/area_basic_shapes-ubuntu.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/area_basic_shapes-ubuntu.png" alt="Area on Ubuntu" loading="lazy"></a><figcaption>Ubuntu</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/area_basic_shapes-windows.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/area_basic_shapes-windows.png" alt="Area on Windows" loading="lazy"></a><figcaption>Windows</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/area_basic_shapes-macos.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/area_basic_shapes-macos.png" alt="Area on macOS" loading="lazy"></a><figcaption>macOS</figcaption></figure>
</div>

## 実行例

{{% shell command="sh scripts/render-example area_basic_shapes" %}}

## 基本構成

`Area::Handler`を作り、`draw`コールバックを登録してから、Handlerを`Area.new`に渡します。Areaは、自身が存在する間Handlerへの参照を保持します。

```crystal
handler = UIng::Area::Handler.new do
  draw do |_area, params|
    brush = UIng::Area::Draw::Brush.new(:solid, 0.2, 0.4, 0.8, 1.0)
    params.context.fill_path(brush) do |path|
      path.add_rectangle(30, 30, 120, 70)
    end
  end
end

area = UIng::Area.new(handler)
window.child = area
```

コントロールの作成前にUIngを初期化し、実行例のようにウィンドウを表示して`UIng.main`を実行します。`Area.new(handler, width, height)`を使うとスクロール可能なAreaになり、指定したサイズはコンテンツの大きさです。

## この章の進め方

このページではAreaの作成と最初の描画を扱います。描画を増やすときは、次の順番で進めると責務を分けやすくなります。

- [パス・ブラシ・線](area-paths-and-brushes.html): 図形、塗り、線、クリッピング
- [テキスト・画像・変換](area-text-images-and-transforms.html): 文字組み、画像、Matrix
- [入力と再描画](area-input-and-redraw.html): マウス・キー入力、状態、アニメーション
- [スクロールと実践例](area-scrolling-and-examples.html): スクロールArea、可視領域、発展例

## 関連作例

<div class="widget-screenshots">
  <figure><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/area_colors_and_brushes.cr"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/area_colors_and_brushes-ubuntu.png" alt="色とブラシ" loading="lazy"></a><figcaption><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/area_colors_and_brushes.cr">色とブラシ</a></figcaption></figure>
  <figure><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/area_analog_clock.cr"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/area_analog_clock-ubuntu.png" alt="アナログ時計" loading="lazy"></a><figcaption><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/area_analog_clock.cr">アナログ時計</a></figcaption></figure>
  <figure><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/area_matrix.cr"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/area_matrix-ubuntu.png" alt="行列変換" loading="lazy"></a><figcaption><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/area_matrix.cr">行列変換</a></figcaption></figure>
  <figure><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/basic_draw_text.cr"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_draw_text-ubuntu.png" alt="テキスト描画" loading="lazy"></a><figcaption><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/basic_draw_text.cr">テキスト描画</a></figcaption></figure>
  <figure><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/reversi.cr"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/reversi-ubuntu.png" alt="Reversi" loading="lazy"></a><figcaption><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/reversi.cr">Reversi</a></figcaption></figure>
  <figure><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/area_breakout.cr"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/area_breakout-ubuntu.png" alt="Breakout" loading="lazy"></a><figcaption><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/area_breakout.cr">Breakout</a></figcaption></figure>
  <figure><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/boid3d.cr"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/boid3d-ubuntu.png" alt="Boid 3D" loading="lazy"></a><figcaption><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/boid3d.cr">Boid 3D</a></figcaption></figure>
</div>

任意のCrImage拡張を使う[画像描画の作例](https://github.com/kojix2/uing/blob/main/examples/crimage/area_draw_image.cr)もあります。

[APIリファレンス](../../api/UIng/Area.html) · [Galleryソース](https://github.com/kojix2/uing/blob/main/examples/gallery/area_basic_shapes.cr)
