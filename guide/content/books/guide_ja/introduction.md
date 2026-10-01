# はじめに

[English](../guide_en/introduction.html)

UIngは、ネイティブなデスクトップインターフェースを提供するポータブルライブラリ
[libui-ng](https://github.com/kojix2/libui-ng)のCrystalバインディングです。
ブラウザエンジンや独自のウィジェットツールキットを同梱せずに、ウィンドウ、
ボタン、テキスト入力、メニュー、テーブル、描画領域などの標準コントロールを
Crystalアプリケーションから利用できます。

同じソースコードで次の環境を対象にできます。

- LinuxなどのUnix系システム: GTK 3
- macOS: AppKit
- Windows: Win32、Direct2D、DirectWrite

UIngには、インターフェースを構築するための同等な2つの書き方があります。
通常のAPIは明示的で分かりやすい書き方です。

<pre><code class="crystal">
window = UIng::Window.new("Hello", 300, 200)
window.child = UIng::Label.new("Hello from UIng")
</code></pre>

ブロックベースのDSLでは、ネストしたレイアウトと実際のコントロール階層を
近い形で記述できます。

<pre><code class="crystal">
UIng::Window.new("Hello", 300, 200) {
  child { UIng::Label.new("Hello from UIng") }
}
</code></pre>

どちらも同じコントロールを使用しており、1つのアプリケーション内で併用できます。

このガイドでは、アプリケーションを作成するために必要な基本概念に絞って説明します。
型とメソッドの完全な一覧は[APIリファレンス](../../api/)を参照してください。
