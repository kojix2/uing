# イベント

[English](../guide_en/events.html)

UIngアプリケーションは、コールバックブロックを使ってネイティブイベントに応答します。
コールバックはインターフェースの構築中、`UIng.main`を呼ぶ前に登録します。

<pre><code class="crystal">
entry = UIng::Entry.new
button = UIng::Button.new("Greet")

button.on_clicked do
  name = entry.text || ""
  window.msg_box("Greeting", "Hello, #{name}!")
end
</code></pre>

必要な場合、コールバックは値を受け取ります。たとえば`Entry#on_changed`は現在の
テキストを、`Slider#on_changed`は現在の整数値を渡します。

<pre><code class="crystal">
entry.on_changed do |text|
  status.text = "#{text.size} characters"
end
</code></pre>

## インターフェースを更新する

ネイティブコントロールの読み書きはUIスレッドで行います。別の場所で実行した処理から
インターフェースを更新する場合は、UIの更新部分だけを`UIng.queue_main`で予約します。

<pre><code class="crystal">
UIng.queue_main do
  status.text = "Finished"
end
</code></pre>

コールバックが参照する可能性のあるコントロールとアプリケーションデータは、
コールバックが使われる間は保持してください。コールバック内の例外はネイティブな
コールバック境界を越えず、UIngによってログに記録されます。
