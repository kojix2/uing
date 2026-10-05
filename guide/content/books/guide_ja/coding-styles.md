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

DSLはCrystalの`with ... yield`構文を内部で使用しています。ブロック内では
コントロールのインスタンスを`self`としてメソッドを呼び出せるため、
`window.child = ...`のような代入の代わりに`child { ... }`と書けます。

## 使い分け

- 通常のAPI: 構造が単純な場合や、コードの流れを明示的に追いたい場合に向きます。
- DSL: 入れ子の深いレイアウトを、実際の階層に近い形で書きたい場合に向きます。

どちらを選んでも生成されるコントロールは同じです。プロジェクト内で
統一しておけば、どちらを使っても問題ありません。
