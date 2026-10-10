# Areaのテキスト

[English](../guide_en/area-text.html)

Areaでは`AttributedString`に文字列と属性を設定し、`TextLayout`を作って描画します。

## 描画の流れ

| 段階 | 型 | 役割 |
| --- | --- | --- |
| 文字列 | `AttributedString` | テキストと部分ごとの属性 |
| 既定フォント | `FontDescriptor` | 属性のない箇所のフォント |
| レイアウト | `TextLayout` | 折り返し、揃え、描画サイズ |
| 描画 | `draw_text_layout` | レイアウトを指定座標へ描く |

```crystal
text = UIng::Area::AttributedString.new("Hello, Area")
text.set_attribute(
  UIng::Area::Attribute.new_color(0.1, 0.2, 0.6, 1.0),
  0, text.len
)
font = UIng::FontDescriptor.new(family: "Sans", size: 14)

handler.draw do |_area, params|
  UIng::Area::Draw::TextLayout.open(
    string: text, default_font: font,
    width: 240, align: :left
  ) do |layout|
    params.context.draw_text_layout(layout, 24, 24)
  end
end
```

`TextLayout.open`はブロック終了時にレイアウトを解放します。`Context`は`draw`中だけ有効です。

## 属性

`set_attribute(attribute, start, end_)`は、バイト範囲へ属性を適用します。UTF-8文字列では文字数をバイト位置として使わず、`String#bytesize`、`AttributedString#len`、`byte_index_to_grapheme`、`grapheme_to_byte_index`で境界を扱います。

| 属性の生成 | 用途 |
| --- | --- |
| `new_family("Sans")` / `new_size(16)` | フォントファミリー・サイズ |
| `new_weight(:bold)` / `new_italic(:italic)` | 太さ・斜体 |
| `new_stretch(:condensed)` | 字幅 |
| `new_color(r, g, b, a)` | 文字色 |
| `new_background(r, g, b, a)` | 背景色 |
| `new_underline(:single)` | 下線 |
| `new_underline_color(:custom, r, g, b, a)` | 下線の色 |
| `new_features(features)` | OpenType機能 |

```crystal
start = text.len
text.append_unattributed(" important")
text.set_attribute(UIng::Area::Attribute.new_weight(:bold), start, text.len)
text.set_attribute(UIng::Area::Attribute.new_underline(:single), start, text.len)
```

`set_attribute`に渡した`Attribute`の所有権は`AttributedString`へ移ります。同じAttributeを再利用・解放してはいけません。別の範囲へ適用する場合も新しく作ります。

## 幅、揃え、大きさ

`width`は折り返しに使う最大幅です。`align`は`:left`、`:center`、`:right`から選びます。`layout.extents`はレイアウトの幅・高さを返します。

```crystal
UIng::Area::Draw::TextLayout.open(
  string: text, default_font: font,
  width: params.area_width - 48,
  align: :center
) do |layout|
  width, height = layout.extents
  params.context.draw_text_layout(layout, 24, 24)
end
```

`TextLayout`は作成時に文字列とフォントをコピーします。静的なテキストはレイアウトを保持して再利用できますが、不要になった時点で`free`します。`AttributedString`と`FontDescriptor`も保持する場合は終了時に`free`します。

[basic_draw_text.cr](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_draw_text.cr)は属性付きテキストの例です。
