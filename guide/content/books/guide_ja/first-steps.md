# 最初のアプリケーション

[English](../guide_en/first-steps.html)

次のアプリケーションは、ボタンを1つ配置したネイティブウィンドウを開きます。
ボタンをクリックするとメッセージボックスが表示されます。

<pre><code class="crystal">
require "uing"

UIng.init do
  window = UIng::Window.new("Hello World", 300, 200)
  window.on_closing do
    UIng.quit
    true
  end

  button = UIng::Button.new("Click me")
  button.on_clicked do
    window.msg_box("UIng", "Hello from Crystal!")
  end

  window.child = button
  window.show
  UIng.main
end
</code></pre>

ソースを`hello.cr`として保存し、実行します。

<pre><code class="bash">
crystal run hello.cr
</code></pre>

## コードの流れ

1. `UIng.init`がネイティブGUIバックエンドを初期化します。
2. `Window.new`と`Button.new`がネイティブコントロールを作成します。
3. `on_clicked`がクリック後に実行する処理を登録します。
4. `window.child`への代入でボタンをウィンドウ内に配置します。
5. `window.show`がインターフェースを表示します。
6. `UIng.main`がイベントループを開始し、終了時のコールバックが`UIng.quit`を呼ぶまで待機します。

`on_closing`から`true`を返すと、ウィンドウを閉じることができます。ブロック形式の
`UIng.init`は、イベントループが終了した後に`UIng.uninit`を自動的に呼び出します。
