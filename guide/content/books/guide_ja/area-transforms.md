# Areaの座標変換

[English](../guide_en/area-transforms.html)

`Matrix`を`context.transform`へ渡すと、それ以降の図形、テキスト、画像の座標系を変換できます。

## 変換の適用範囲

変換はContextに残るため、通常は`save`と`restore`で囲みます。要素ごとにこの範囲を作ると、変換がほかの描画へ影響しません。

```crystal
context = params.context
matrix = UIng::Area::Draw::Matrix.new
matrix.set_identity
matrix.translate(160, 100)
matrix.rotate(160, 100, Math::PI / 6)

context.save
begin
  context.transform(matrix)
  context.draw_image(image, 0, 0, 80, 80)
ensure
  context.restore
end
```

## Matrixの操作

| メソッド | 効果 |
| --- | --- |
| `set_identity` | 単位行列へ戻す |
| `translate(x, y)` | 平行移動 |
| `scale(cx, cy, sx, sy)` | `(cx, cy)`を中心に拡大縮小 |
| `rotate(cx, cy, angle)` | `(cx, cy)`を中心に回転。`angle`はラジアン |
| `skew(x, y, x_amount, y_amount)` | `(x, y)`を基準にせん断 |
| `multiply(other)` | 別のMatrixを合成 |
| `invertible?` / `invert` | 逆行列の可否確認と反転 |
| `transform_point` / `transform_size` | 座標・大きさをMatrixで変換 |

変換の順序は結果に影響します。基準点の周りで回転・拡大縮小するには、`rotate`や`scale`の中心にその点を渡します。

`Matrix`はCrystalオブジェクトで、明示的な解放は不要です。`Context`は`draw`中だけ有効です。

[area_matrix.cr](https://github.com/kojix2/uing/blob/main/examples/gallery/area_matrix.cr)は平行移動、拡大縮小、回転、せん断を操作する例です。
