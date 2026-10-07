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

`UIng.quit`はイベントループを停止しますが、開いているすべてのウィンドウを破棄する
わけではありません。通常のウィンドウ終了コールバックは`true`を返し、ウィンドウを
閉じるときにlibui-ngが破棄できるようにします。

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

`Window#on_closing`はウィンドウの閉じるボタンを処理します。`true`を返すと
libui-ngがウィンドウを閉じて破棄し、`false`を返すと開いたままにします。
単一ウィンドウのアプリケーションでは、イベントループを停止して`true`を返します。

<pre><code class="crystal">
window.on_closing do
  UIng.quit
  true
end
</code></pre>

この経路では`window.destroy`を呼ばないでください。コールバックが`true`を返した後、
libui-ngがウィンドウを破棄します。

`UIng.on_should_quit`は、終了メニューなどアプリケーション全体の終了要求を処理します。
このコールバックは最上位ウィンドウを自動的には破棄しません。両方のコールバックを
使う場合は、`on_should_quit`ですべての最上位ウィンドウを破棄し、二重破棄を避ける
ために`released?`を使います。

<pre><code class="crystal">
window.on_closing do
  UIng.quit
  true
end

UIng.on_should_quit do
  window.destroy unless window.released?
  true
end
</code></pre>

## その他のリソース

コントロール以外のオブジェクトは、取得方法に応じた規則で解放します。

- `.new`で作成したオブジェクトやメソッドから直接返されたオブジェクトは、通常、
  使用後に解放する必要があります。
- `.open`などのブロック形式で使うオブジェクトは、ブロック終了時に自動解放されます。
- コールバックへ渡されたオブジェクトは、通常、そのコールバックが返るまでだけ有効です。
  解放はUIngが処理します。

個別のリソースには次の規則があります。

- `Table::Model`: `model.free`の前に、そのモデルを使用するすべての`Table`の破棄を
  要求します。ネイティブ側の破棄が保留中の場合、ラッパーは直ちに利用不能になり、
  最後のTableの破棄完了後にネイティブモデルが解放されます。
- `Image`: 不要になったら`free`を呼びます。`ImageView#image=`へ渡した後は解放できますが、
  Tableまたは`Toolbar`が使用している間は保持してください。
- `Toolbar`: ウィンドウから切り離してから`free`を呼びます。
- `Draw::Path`、`Draw::TextLayout`、`AttributedString`: 利用できる場合は`.open`を使い、
  ブロック終了時に解放させます。
- `Table::Selection`: ブロック形式とコールバック形式では自動解放されます。
  `table.selection`の直接の戻り値は使用後に解放します。`Table::Selection.new(rows)`は
  CrystalのGCが管理します。
- `Table::Value`: `cell_value`から返した値はlibui-ngが管理します。`set_cell_value`へ
  渡された値は、そのコールバックが返るまでだけ有効です。
- `Attribute`: `set_attribute`へ渡した後は、受け取った`AttributedString`が管理します。
  列挙中にyieldされたAttributeは、そのブロック内だけで有効です。
- `OpenTypeFeatures`と`AttributedString`は列挙中に再帰的に読み取れますが、列挙が
  終わるまでは解放や構造変更ができません。
- 描画コンテキストはdrawコールバック中だけ有効です。

`destroy`または`free`を呼ぶと、対応するラッパーは以後利用できません。
