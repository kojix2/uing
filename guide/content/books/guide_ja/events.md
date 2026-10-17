# イベント

[English](../guide_en/events.html)

UIngアプリケーションは、コールバックブロックを使ってネイティブイベントに応答します。
コールバックはインターフェースの構築中、`UIng.main`を呼ぶ前に登録します。次は
[最初のアプリケーション](first-steps.html)で作成した`window`を使う抜粋です。

<pre><code class="crystal">
entry = UIng::Entry.new
button = UIng::Button.new("Greet")
status = UIng::Label.new("Enter your name")

button.on_clicked do
  name = entry.text || ""
  window.msg_box("Greeting", "Hello, #{name}!")
end

entry.on_changed do |text|
  status.text = "#{text.size} characters"
end
</code></pre>

必要な場合、コールバックは値を受け取ります。たとえば`Entry#on_changed`は現在の
テキストを、`Slider#on_changed`は現在の整数値を渡します。

## コールバックの解除

各`on_*`登録には対応する`clear_on_*`があります。たとえば
`button.clear_on_clicked`は`button.on_clicked(nil)`と同じで、
`entry.clear_on_changed`は`entry.on_changed(nil)`と同じです。解除すると
Crystalのクロージャへの参照を解放し、コントロールは後で再登録できます。
MenuItem、ToolbarItem、Table、Window、`UIng.clear_on_should_quit`も同じ規則です。
`Area::Handler`では`clear_draw`や`clear_mouse_event`などを使い、対応する
登録メソッドへ`nil`を渡す場合と同じです。
`MultilineEntry#clear_on_changed`と`#clear_on_changed_with_text`は同じ変更通知の
登録枠を解除します。任意の編集コールバックには
`Table::Model::Handler#clear_set_cell_value`も使え、`set_cell_value(nil)`と同じです。
`UIng.clear_on_error`は`UIng.on_error(nil)`と同じです。

libui-ngがNULLでない関数ポインタを必要とする箇所には、解除後も何もしない
ネイティブコールバックを残します。`window.clear_on_closing`の後は、新規Windowで
終了ハンドラを登録していない場合と同様に、閉じる要求を拒否します。
`UIng.clear_on_should_quit`の後もアプリケーション全体の終了要求を拒否します。
どちらかの要求に応答させる場合は、改めてハンドラを登録してください。

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
