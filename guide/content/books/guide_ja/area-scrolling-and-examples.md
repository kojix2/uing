# Areaのスクロールと実践例

[English](../guide_en/area-scrolling-and-examples.html)

`Area.new(handler, width, height)`は、指定したコンテンツサイズを持つスクロールAreaを作ります。通常の`Area.new(handler)`と異なり、`params.area_width`と`params.area_height`は使いません。コンテンツサイズはアプリケーション側で管理します。

```crystal
content_width = 2_000
content_height = 1_200
area = UIng::Area.new(handler, content_width, content_height)

# コンテンツが広がった後にサイズを更新する
content_width += 400
area.set_size(content_width, content_height)

# 特定の矩形が見える位置まで移動する
area.scroll_to(200, 100, 400, 300)
```

`draw`ではクリップ矩形を使って可視領域だけを描画します。大量の図形・画像・文字列を扱う場合は、静的なPathやBrushを再利用し、可視範囲外の要素をスキップします。

## 次に読む作例

- [area_breakout.cr](https://github.com/kojix2/uing/blob/main/examples/gallery/area_breakout.cr): ゲームループと入力
- [boid3d.cr](https://github.com/kojix2/uing/blob/main/examples/gallery/boid3d.cr): 多数のオブジェクトの描画
- [air_hockey](https://github.com/kojix2/uing/tree/main/examples/air_hockey): 状態、入力、投影、描画を分けた実践的な構成

Areaの規模が大きくなったら、モデル、入力、描画を別々の型またはファイルに分けます。描画関数は状態を読み取るだけに保つと、再描画の原因とリソースの寿命を追いやすくなります。
