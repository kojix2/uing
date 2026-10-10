# Areaのパス・ブラシ・線

[English](../guide_en/area-paths-and-brushes.html)

`draw`内で`params.context`を使って描画します。Contextはコールバック中だけ有効です。

## 塗りと線

`fill_path`と`stroke_path`は、パスの終了と解放を行います。通常はこちらを使います。

```crystal
handler = UIng::Area::Handler.new do
  draw do |_area, params|
    fill = UIng::Area::Draw::Brush.new(:solid, 0.2, 0.4, 0.8, 1.0)
    params.context.fill_path(fill) { |path| path.add_rectangle(24, 24, 160, 80) }

    line = UIng::Area::Draw::Brush.new(:solid, 0.1, 0.1, 0.1, 1.0)
    params.context.stroke_path(line, thickness: 2.0) do |path|
      path.new_figure(24, 128).line_to(184, 184)
    end
  end
end
```

同じパスを塗りと線の両方に使う場合は`draw_path`を使います。`fill_brush`、`stroke_brush`、`stroke_params`を指定します。

## Brush

`Brush.new`は`:solid`、`:linear_gradient`、`:radial_gradient`を受け取ります。色成分`r`、`g`、`b`、`a`は0.0から1.0で、`a`は不透明度です。

| 種類 | 指定値 |
| --- | --- |
| 単色 | `:solid, r, g, b, a` |
| 線形グラデーション | `:linear_gradient, x0:, y0:, x1:, y1:, stops:` |
| 放射状グラデーション | `:radial_gradient, x0:, y0:, x1:, y1:, outer_radius:, stops:` |

線形グラデーションは`x0, y0`から`x1, y1`へ変化します。放射状グラデーションの`x0, y0`は内側、`x1, y1`と`outer_radius`は外側の円です。

```crystal
stops = [
  UIng::Area::Draw::Brush::GradientStop.new(0.0, 1.0, 0.8, 0.0, 1.0),
  UIng::Area::Draw::Brush::GradientStop.new(1.0, 1.0, 0.1, 0.0, 1.0),
]

linear = UIng::Area::Draw::Brush.new(
  :linear_gradient, x0: 24, y0: 24, x1: 184, y1: 24, stops: stops
)
radial = UIng::Area::Draw::Brush.new(
  :radial_gradient, x0: 100, y0: 100, x1: 100, y1: 100,
  outer_radius: 60, stops: stops
)
```

`GradientStop`の位置と色成分も0.0から1.0です。停止位置は小さい順に指定します。`require "uing/crimage"`を使うと、`Brush.solid(color)`と`GradientStop.new(position, color)`にCrImageの色を渡せます。

## パス

`new_figure`または`new_figure_with_arc`で図形を開始します。`add_rectangle`は矩形を追加します。閉じた輪郭には`close_figure`を使います。

| 図形 | メソッド |
| --- | --- |
| 矩形 | `add_rectangle(x, y, width, height)` |
| 直線 | `new_figure(x, y)` → `line_to(x, y)` |
| 3次ベジェ曲線 | `bezier_to(c1x, c1y, c2x, c2y, end_x, end_y)` |
| 円弧から開始 | `new_figure_with_arc(x, y, radius, start_angle, sweep, negative)` |
| 円弧を追加 | `arc_to(x, y, radius, start_angle, sweep, negative)` |

角度はラジアンです。`start_angle`は開始角、`sweep`は描画角、`negative`は向きです。

```crystal
params.context.fill_path(brush) do |path|
  path.new_figure(80, 20).line_to(140, 120).line_to(20, 120).close_figure # 三角形
  path.new_figure_with_arc(220, 70, 40, 0, Math::PI * 2, false)             # 円
end

params.context.stroke_path(brush, thickness: 2.0) do |path|
  path.new_figure(20, 100)
  path.bezier_to(70, 20, 130, 180, 180, 100)
end

params.context.fill_path(brush) do |path| # 扇形
  path.new_figure(100, 100)
  path.arc_to(100, 100, 60, 0, Math::PI / 2, false)
  path.close_figure
end
```

## 線、塗り規則、クリッピング

`StrokeParams`では`thickness`、`cap`（`:flat`、`:round`、`:square`）、`join`（`:miter`、`:round`、`:bevel`）、`miter_limit`、`dashes`、`dash_phase`を指定します。

```crystal
dashed = UIng::Area::Draw::StrokeParams.new(
  thickness: 4.0, cap: :round, join: :round, dashes: [8.0, 4.0]
)
```

自己交差や穴のある形では、`fill_path`または`draw_path`の`mode:`に`:winding`（既定）か`:alternate`を指定します。描画範囲を絞るには`clip_path`を`save`と`restore`で囲みます。

```crystal
context.save
context.clip_path { |path| path.add_rectangle(0, 0, 120, 80) }
# この範囲だけ描画
context.restore
```

`Path.open`を使う場合は、描画前に`end_path`を呼びます。ブロックを抜けるとパスは解放されます。`params.clip_x`、`clip_y`、`clip_width`、`clip_height`は、再描画が必要な範囲です。

[area_basic_shapes.cr](https://github.com/kojix2/uing/blob/main/examples/gallery/area_basic_shapes.cr)と[area_colors_and_brushes.cr](https://github.com/kojix2/uing/blob/main/examples/gallery/area_colors_and_brushes.cr)も参照してください。
