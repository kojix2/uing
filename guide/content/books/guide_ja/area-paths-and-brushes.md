# Areaのパス・ブラシ・線

[English](../guide_en/area-paths-and-brushes.html)

`draw`コールバックでは、`params.context`を使ってパスを塗りつぶしたり線で描いたりします。Contextはこのコールバックの実行中だけ有効です。

## 塗りと線

`fill_path`と`stroke_path`のブロック形式は、パスを終了・解放します。最初はこの形式を使うと安全です。

```crystal
handler = UIng::Area::Handler.new do
  draw do |_area, params|
    blue = UIng::Area::Draw::Brush.new(:solid, 0.2, 0.4, 0.8, 1.0)
    params.context.fill_path(blue) do |path|
      path.add_rectangle(24, 24, 160, 80)
    end

    outline = UIng::Area::Draw::Brush.new(:solid, 0.1, 0.1, 0.1, 1.0)
    stroke = UIng::Area::Draw::StrokeParams.new(thickness: 2.0)
    params.context.stroke_path(outline, stroke) do |path|
      path.new_figure(24, 128)
      path.line_to(184, 184)
    end
  end
end

area = UIng::Area.new(handler)
```

色成分`r`、`g`、`b`、`a`は0.0から1.0です。`Brush`は単色のほか、線形・放射状グラデーションを表せます。`StrokeParams`で太さ、端点、結合方法、破線を指定します。

## パスと可視領域

パスには矩形、直線、ベジェ曲線、円弧を追加できます。直接`Path.open`を使う場合は、描画前に`end_path`を呼び、不要になったら解放します。頻繁に描く静的な形状は、Pathを再利用すると負荷を抑えられます。

`params.clip_x`、`clip_y`、`clip_width`、`clip_height`は、現在描画すべき範囲です。大きなキャンバスでは、この範囲の外にあるオブジェクトを描かないようにします。

[area_colors_and_brushes.cr](https://github.com/kojix2/uing/blob/main/examples/gallery/area_colors_and_brushes.cr)は単色、透過、グラデーションの例です。
