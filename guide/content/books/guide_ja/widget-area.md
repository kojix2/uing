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

## 描画

- `draw`は描画が必要なときに呼ばれます。`params.area_width`と`params.area_height`は非スクロールAreaのみ有効です。スクロールAreaのコンテンツサイズはアプリ側で管理します。`clip_x`、`clip_y`、`clip_width`、`clip_height`は描画対象の範囲です。
- `params.context`の`fill_path`／`stroke_path`で描画すると、パスの終了・解放は自動です。直接`Path.open`を使う場合は描画前に`end_path`を呼びます。ブラシの色成分（`r`、`g`、`b`、`a`）は0.0から1.0の範囲です。
- 描画Contextは`draw`の実行中だけ有効です。保存してコールバック終了後に使わないでください。

## 使い方

- Handlerに`mouse_event`、`mouse_crossed`、`drag_broken`、`key_event`を登録して入力を処理できます。マウス座標はイベントから取得できます。`key_event`はキーを処理した場合`true`、それ以外は`false`を返します。
- アプリケーションの状態は描画コールバックの外で管理します。入力コールバックやタイマーで状態を更新した後、`area.queue_redraw_all`を呼んで次の描画を要求します。これは描画を即時実行するのではなく、再描画を予約します。
- `set_size`と`scroll_to`はスクロールArea専用です。`begin_user_window_move`／`begin_user_window_resize`は、`mouse_event`内の`event.down != 0`のときだけ呼べます。

## 関連作例

<div class="widget-screenshots">
  <figure><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/area_colors_and_brushes.cr"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/area_colors_and_brushes-ubuntu.png" alt="色とブラシ" loading="lazy"></a><figcaption><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/area_colors_and_brushes.cr">色とブラシ</a></figcaption></figure>
  <figure><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/area_analog_clock.cr"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/area_analog_clock-ubuntu.png" alt="アナログ時計" loading="lazy"></a><figcaption><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/area_analog_clock.cr">アナログ時計</a></figcaption></figure>
  <figure><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/area_matrix.cr"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/area_matrix-ubuntu.png" alt="行列変換" loading="lazy"></a><figcaption><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/area_matrix.cr">行列変換</a></figcaption></figure>
  <figure><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/basic_draw_text.cr"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_draw_text-ubuntu.png" alt="テキスト描画" loading="lazy"></a><figcaption><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/basic_draw_text.cr">テキスト描画</a></figcaption></figure>
  <figure><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/reversi.cr"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/reversi-ubuntu.png" alt="Reversi" loading="lazy"></a><figcaption><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/reversi.cr">Reversi</a></figcaption></figure>
  <figure><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/area_breakout.cr"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/area_breakout-ubuntu.png" alt="Breakout" loading="lazy"></a><figcaption><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/area_breakout.cr">Breakout</a></figcaption></figure>
  <figure><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/boid3d.cr"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/boid3d-ubuntu.png" alt="Boid 3D" loading="lazy"></a><figcaption><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/boid3d.cr">Boid 3D</a></figcaption></figure>
  <figure><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/area_draw_image.cr"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/area_draw_image-ubuntu.png" alt="画像描画" loading="lazy"></a><figcaption><a href="https://github.com/kojix2/uing/blob/main/examples/gallery/area_draw_image.cr">画像描画</a></figcaption></figure>
</div>

[APIリファレンス](../../api/UIng/Area.html) · [Galleryソース](https://github.com/kojix2/uing/blob/main/examples/gallery/area_basic_shapes.cr)
