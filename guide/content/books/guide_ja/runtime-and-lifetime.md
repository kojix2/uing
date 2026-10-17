# ランタイムとライフタイム

[English](../guide_en/runtime-and-lifetime.html)

UIngアプリケーションは、`UIng.init`から`UIng.main`までの間にコントロールを作成します。
メインループはネイティブイベントを待機し、アプリケーションが登録したコールバックを
呼び出します。

## アプリケーションのライフサイクル

- `UIng.init`はlibui-ngを初期化します。
- `window.show`は構築済みのウィンドウを表示します。
- `UIng.main`はネイティブイベントループを実行します。
- `UIng.quit`はイベントループに終了を要求します。
- `UIng.uninit`はイベントループ終了後にアプリケーション全体のリソースを解放します。

対応する`UIng.uninit`を呼び忘れないよう、`UIng.main`の後には必ず`UIng.uninit`を
呼んでください。

<pre><code class="crystal">
UIng.init

# ここでインターフェースを構築して表示します。
UIng.main
UIng.uninit
</code></pre>

`UIng.init`にブロックを渡す書き方もあります。この形式では、イベントループが
終了した後に`UIng.uninit`が自動的に呼び出されます。

<pre><code class="crystal">
UIng.init do
  # ここでインターフェースを構築して表示します。
  UIng.main
end
</code></pre>

ブロック形式が保証するのは`init`と`uninit`の対応です。ブロック内で作成したWindowや
その他のリソースは自動では破棄されません。例外でブロックを抜ける場合も含め、
すべての最上位Windowをブロック終了前に破棄し、独立したリソースは後述の所有権規則に
従って解放してください。画面構築中に例外が発生すると、Windowが残ったまま`uninit`へ
進む可能性があります。

## 単一ウィンドウの終了

通常はコントロールを手動で破棄する必要はありません。`on_closing`でイベントループを
停止して`true`を返すと、libui-ngがWindowとその子を破棄します。

<pre><code class="crystal">
window.on_closing do
  UIng.quit
  true
end
</code></pre>

このコールバック内では`window.destroy`を呼びません。

## コントロールの所有権

一部のコントロールは別のコントロールを内包します。内包する側が親、接続された側が
子です。親を破棄するとすべての子も自動的に破棄されるため、通常は最上位の親だけを
破棄します。

<pre><code class="crystal">
window = UIng::Window.new("App", 400, 300)
box = UIng::Box.new(:vertical)
button = UIng::Button.new("OK")

box.append(button)
window.child = box

window.destroy # boxとbuttonも破棄されます
</code></pre>

UIngは子のCrystalラッパーも解放済みとして扱います。親を破棄した後に子を使用する
ことはできません。

子を別の場所で再利用する場合は、先に親から切り離します。

<pre><code class="crystal">
button.detach
other_box.append(button)
</code></pre>

子を個別に破棄する場合も、先に切り離します。

<pre><code class="crystal">
button.detach
button.destroy
</code></pre>

接続中の子に`destroy`を呼ぶと例外が発生し、子は破棄されずに残ります。

- `Window`と`Group`は子を1つ持ちます。`nil`または新しい子を代入すると、以前の子は
  破棄されずに切り離されます。
- `Box`、`Form`、`Tab`、`Grid`は`delete(child)`を利用できます。`Box`、`Form`、
  `Tab`では`delete(index)`も利用できます。
- 親を持たないコントロールは直接破棄できます。

## ウィンドウとアプリケーションの終了

`UIng.quit`はイベントループを停止しますが、ウィンドウを破棄しません。
`UIng.uninit`はアプリケーション全体のリソースを解放しますが、アプリケーションが
作成したウィンドウを破棄しません。`UIng.uninit`を呼ぶ前に、すべての最上位
ウィンドウが破棄されていることを確認してください。

`Window#on_closing`は閉じるボタンを処理します。`true`ならWindowを閉じ、`false`なら
開いたままにします。複数Windowでは、各Windowを閉じるたびに無条件で`UIng.quit`を
呼ばないでください。

`UIng.on_should_quit`はQuitメニューなど、アプリケーション全体の終了要求を処理します。
すべての最上位Windowを破棄してから`true`を返します。

<pre><code class="crystal">
UIng.on_should_quit do
  window.destroy unless window.released?
  true
end
</code></pre>

複数Windowでは同じ処理をすべての最上位Windowに行います。`released?`は二重破棄を防ぎます。

## その他のリソース

コントロール以外には、Crystalが管理する値と、明示的な解放が必要なネイティブ資源が
あります。`.new`で作ったか、メソッドから受け取ったかだけでは区別できません。

- `.open`で使うネイティブ資源は、ブロック終了時に自動解放されます。
- コールバックへ渡された値を後で使えるかどうかは型によって異なります。
  `Table::Selection`と`FontDescriptor`は保持できますが、借用された`Table::Value`や
  `Attribute`はコールバック終了後に使えません。

個別のリソースには次の規則があります。

- `Table::Model`: `model.free`の前に、そのモデルを使用するすべての`Table`の破棄を
  要求します。ネイティブ側の破棄が保留中の場合、ラッパーは直ちに利用不能になり、
  最後のTableの破棄完了後にネイティブモデルが解放されます。
- `Image`: 不要になったら`free`を呼びます。`ImageView#image=`へ渡した後は解放できますが、
  Tableまたは`Toolbar`が使用している間は保持してください。
- `Toolbar`: ウィンドウから切り離してから`free`を呼びます。
- `Draw::Path`、`Draw::TextLayout`、`AttributedString`: 利用できる場合は`.open`を使い、
  ブロック終了時に解放させます。
- `Table::Selection`: `table.selection`の戻り値、コールバックで受け取った値、
  `Table::Selection.new(rows)`で作った値は、いずれも独立したスナップショットです。
  コールバックの外でも保持でき、`free`は不要です。
- `FontDescriptor`: `FontButton#font`の戻り値とコールバックで受け取った値を保持できます。
  Crystalが管理するため、`free`は不要です。
- `OpenTypeFeatures`: タグと値はCrystalが管理します。`Attribute.new_features`へ渡した後も
  再利用でき、`free`は不要です。`Attribute#features`も独立したコピーを返します。
- `TM`: Crystalが管理します。Windows以外では`zone=`に渡した文字列をコピーして保持します。
  `free`は不要です。
- `Table::Value`: `cell_value`から返した値はlibui-ngが管理します。`set_cell_value`へ
  渡された値は、そのコールバックが返るまでだけ有効です。渡さずに作った値は`free`します。
- `Attribute`: `set_attribute`へ渡した後は、受け取った`AttributedString`が管理します。
  列挙中にyieldされたAttributeは、そのブロック内だけで有効です。
- `OpenTypeFeatures`は列挙中に再帰的に読み取れますが、追加や削除はできません。
  `AttributedString`も列挙中に再帰的に読み取れますが、列挙が終わるまでは解放や
  構造変更ができません。
- 描画コンテキストはdrawコールバック中だけ有効です。

`destroy`または`free`を呼ぶと、対応するラッパーは以後利用できません。
