# Areaの入力と再描画

[English](../guide_en/area-input-and-redraw.html)

描画コールバックは状態を表示する場所です。状態変更は入力コールバックやタイマーで行い、変更後に`queue_redraw_all`で次の描画を予約します。`queue_redraw_all`は直ちに描画するAPIではありません。

```crystal
x = 80.0
y = 80.0
brush = UIng::Area::Draw::Brush.new(:solid, 0.2, 0.4, 0.8, 1.0)

handler = UIng::Area::Handler.new do
  draw do |_area, params|
    params.context.fill_path(brush) do |path|
      path.add_rectangle(x, y, 24, 24)
    end
  end

  mouse_event do |area, event|
    x = event.x
    y = event.y
    area.queue_redraw_all
  end

  key_event do |area, event|
    handled = !event.up? && event.ext_key == UIng::Area::ExtKey::Left
    x -= 8 if handled
    area.queue_redraw_all if handled
    handled
  end
end

area = UIng::Area.new(handler)
```

## 入力コールバック

- `mouse_event`は座標、ボタン、修飾キーを受け取ります。
- `mouse_crossed`はポインタがAreaへ出入りしたことを受け取ります。
- `drag_broken`はドラッグ操作が中断されたときに状態を戻すために使えます。
- `key_event`は処理済みなら`true`、処理しなければ`false`を返します。

`begin_user_window_move`と`begin_user_window_resize`は、`mouse_event`内かつ`event.down != 0`のときだけ呼びます。アニメーションでは、描画資源の生成を毎フレーム繰り返さず、変更された状態だけを再描画します。

[area_analog_clock.cr](https://github.com/kojix2/uing/blob/main/examples/gallery/area_analog_clock.cr)と[reversi.cr](https://github.com/kojix2/uing/blob/main/examples/gallery/reversi.cr)は、状態と再描画を組み合わせた例です。
