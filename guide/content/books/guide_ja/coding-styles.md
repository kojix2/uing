# コーディングスタイル

[English](../guide_en/coding-styles.html)

UIngには、インターフェースを構築するための同等な2つの書き方があります。
どちらも同じコントロールを使用しており、1つのアプリケーション内で併用できます。

## 通常のAPI

通常のAPIは明示的で分かりやすい書き方です。このガイドでは主にこの形式を
使用します。

<pre><code class="crystal">
window = UIng::Window.new("Hello", 300, 200)
window.child = UIng::Label.new("Hello from UIng")
</code></pre>

## ブロックベースのDSL

ブロックベースのDSLでは、ネストしたレイアウトと実際のコントロール階層を
近い形で記述できます。

<pre><code class="crystal">
UIng::Window.new("Hello", 300, 200) {
  child { UIng::Label.new("Hello from UIng") }
}
</code></pre>

複雑な入れ子構造の例です。

<pre><code class="crystal">
UIng.init do
  UIng::Window.new("Hello World", 300, 200) { |win|
    on_closing { UIng.quit; true }
    child {
      UIng::Button.new("Click me") {
        on_clicked {
          win.msg_box("Info", "Button clicked!")
        }
      }
    }
    show
  }

  UIng.main
end
</code></pre>

`do ... end`と`{ ... }`は、どちらもブロックを渡す書き方です。
以下では、よく使うブロックの役割と通常のAPIとの対応を説明します。

## 作ったオブジェクトを設定する: `new do ... end`

ブロック構築に対応するクラスでは、`new`のブロック内で、作ったオブジェクトの
メソッドをレシーバなしで呼べます。次の2つは同じ設定を行います。

<pre><code class="crystal">
# 通常のAPI
button = UIng::Button.new("Save")
button.on_clicked { puts "Save clicked" }

# ブロック構築
button = UIng::Button.new("Save") do
  on_clicked { puts "Save clicked" }
end
</code></pre>

`new`は、ブロックの最後の式によらず、生成したオブジェクトを返します。
ただし、生成しただけでは親には取り付けられません。`child`や`append`で
取り付けます。Windowの表示にも`show`が必要です。

必要なら`do |button|`のようにオブジェクトを引数で受け取れます。
プロパティへの代入には、この明示的な参照を使います。

<pre><code class="crystal">
button = UIng::Button.new("Save") do |button|
  button.tooltip = "Save the document"
  on_clicked { puts "Save clicked" }
end
</code></pre>

`tooltip = "..."`だけではローカル変数への代入になるため、
`button.tooltip = "..."`と書きます。

内部ではCrystalの`with ... yield`を使っています。これはレシーバを省略した
メソッド呼び出しの探索先を追加する仕組みで、`self`自体は変わりません。
外側のローカル変数も使えます。インスタンスメソッド内で書いた`@entry`などの
インスタンス変数は、その外側のインスタンスのものを参照します。

## ブロックの結果を子にする: `child do ... end`

WindowとGroupの`child`は、ブロックをその場で実行し、返されたControlを
子に設定します。次の2つは同じ意味です。

<pre><code class="crystal">
window.child = UIng::Label.new("Hello")

window.child do
  UIng::Label.new("Hello")
end
</code></pre>

ブロックの最後の式が、取り付けるControlである必要があります。
`child`自体はレシーバを切り替えません。子の設定には、さらにその子の
`new`のブロックを使えます。

<pre><code class="crystal">
window.child do
  UIng::Box.new(:vertical, padded: true) do
    append UIng::Label.new("Name")
    append UIng::Entry.new, stretchy: true
  end
end
</code></pre>

この例ではBoxの`new`がBoxを返し、`child`がそれをWindowに取り付けます。
Box内の`append`は、そのBoxのメソッドです。次のようにも書けます。

<pre><code class="crystal">
box = UIng::Box.new(:vertical, padded: true)
box.append(UIng::Label.new("Name"))
box.append(UIng::Entry.new, stretchy: true)
window.child = box
</code></pre>

## 子を追加するブロックの一覧

次のブロックもその場で実行され、最後の式が返した子を取り付けます。
ブロック内でレシーバは切り替わりません。表の`control`と`bar`は、
生成済みのControlとToolbar、`parent`はWindowまたはGroupを表します。

| 対象 | ブロック形式 | 通常のAPIでの対応 |
| --- | --- | --- |
| Window、Group | `child { control }` | `parent.child = control` |
| Window、Group | `set_child { control }` | `parent.set_child(control)`（`child`の別名） |
| Box | `append(stretchy: true) { control }` | `box.append(control, stretchy: true)` |
| Form | `append("Name") { control }` | `form.append("Name", control)` |
| Grid | `append(left: 0, top: 0) { control }` | `grid.append(control, left: 0, top: 0)` |
| Grid | `insert_at(existing, :trailing) { control }` | `grid.insert_at(control, existing, :trailing)` |
| Tab | `append("Page", margined: true) { control }` | `tab.append("Page", control, margined: true)` |
| Tab | `insert_at("Page", 0) { control }` | `tab.insert_at("Page", 0, control)` |
| Window | `toolbar { bar }` | `window.toolbar = bar` |

`stretchy`、`margined`、Gridの座標や配置オプションは、通常のAPIと同じ意味です。
既存の親を使う場合は、`box.append(stretchy: true) do ... end`のように
レシーバを明示して呼べます。

`Box#append`などの追加メソッド自体の戻り値は`Nil`です。
`child`の最後の式が`box.append(...)`になると、Controlを返せません。
その場合は最後に`box`を置くか、上の例のように`Box.new do ... end`を使います。

## メニュー項目・ツールバー項目の設定ブロック

これらは、項目を先に作り、その項目のメソッドをレシーバなしで呼べる
設定ブロックを実行します。戻り値は、ブロックの最後の式によらず生成した項目です。

| 対象 | 設定ブロックを渡せるメソッド | 設定対象・戻り値 |
| --- | --- | --- |
| Menu | `append_item`、`append_check_item` | MenuItem |
| Menu | `append_preferences_item`、`append_about_item`、`append_quit_item` | MenuItem |
| Toolbar | `append_button`、`append_toggle_button` | ToolbarItem |

<pre><code class="crystal">
UIng::Menu.new("File") do
  append_item("Open") do
    set_shortcut('O', UIng::Modifiers::Primary)
    on_clicked { |window| window.try &amp;.open_file }
  end
end
</code></pre>

この例の`append_item`はMenu、`set_shortcut`と`on_clicked`は生成した
MenuItemのメソッドです。`do |item|`で項目を受け取ることもできます。

Menuは最初のWindowより先に作ります。Quit項目の終了処理は
`on_clicked`ではなく`UIng.on_should_quit`に登録します。Toolbarの項目は
最初の取り付けより先に追加します。詳しくは[Menu](widget-menu.html)と
[Toolbar](widget-toolbar.html)を参照してください。

## イベントやライフサイクルのブロックとの違い

同じブロック構文でも、呼び出すメソッドによって実行のタイミングと意味が異なります。

| 書き方 | 実行のタイミング・役割 |
| --- | --- |
| `new do ... end`、項目の設定ブロック | 作成時にその場で設定する |
| `child do ... end`、子を追加するブロック | その場で実行し、返された子を取り付ける |
| `on_clicked do ... end`など | コールバックを登録し、イベント発生時に実行する |
| `Handler.new`内の`draw`、`num_rows`など | コールバックを登録し、描画やデータの問い合わせ時に実行する |
| `UIng.init do ... end` | 初期化後に実行し、ブロック終了時に`uninit`する |

たとえば`Area::Handler.new do ... end`内の`draw do ... end`は、
その場で描画する命令ではありません。`handler.draw do ... end`と同じ描画
コールバックの登録です。`Table::Model::Handler`の`num_rows { rows.size }`も、
行数を問い合わせられたときの処理を登録します。詳しくは[Area](widget-area.html)と
[Tableのモデルとデータ供給](table-model.html)を参照してください。

`UIng.init`のブロックは、通常のAPIでもDSLでも使えます。
個別リソースの解放方法は[ランタイムと寿命管理](runtime-and-lifetime.html)を参照してください。

## 使い分け

- 通常のAPI: 構造が単純な場合や、コードの流れを明示的に追いたい場合に向きます。
- DSL: 入れ子の深いレイアウトを、実際の階層に近い形で書きたい場合に向きます。

どちらを選んでも生成されるコントロールは同じです。プロジェクト内で
統一しておけば、どちらを使っても問題ありません。
