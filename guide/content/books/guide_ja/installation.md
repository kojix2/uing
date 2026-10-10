# インストール

[English](../guide_en/installation.html)

## 前提条件

CrystalとShardsが必要です。UIngはCrystalの最新版で継続的にテストされています。

アプリケーションの`shard.yml`にUIngを追加します。

<pre><code class="yaml">
dependencies:
  uing:
    github: kojix2/uing
</code></pre>

依存関係をインストールします。

<pre><code class="bash">
shards install
</code></pre>

インストール後のスクリプトが、現在のプラットフォームに対応するlibui-ngライブラリを
[kojix2/libui-ngのリリース](https://github.com/kojix2/libui-ng/releases)から
ダウンロードします。UIngは対応プラットフォーム向けに保守されたパッチ適用版を使用します。
パッチの詳細はlibui-ngの
[`dev`ブランチ](https://github.com/kojix2/libui-ng/commits/dev)で確認できます。

## プラットフォームごとの注意事項

### Linux

アプリケーションをビルドする前にGTK 3の開発パッケージをインストールしてください。
パッケージ名はディストリビューションによって異なります。DebianとUbuntuでは
`libgtk-3-dev`です。

<pre><code class="bash">
sudo apt install libgtk-3-dev
</code></pre>

配布先にもGTK 3のランタイムが必要です。

### macOS

ネイティブGUIの依存関係には、システムのAppKitフレームワークを使用します。
Intel MacとApple Siliconの両方に対応しています。

### Windows

UIngはMSVC、MinGW64、UCRT64に対応しています。Crystalと同じツールチェーンを使います。
MSVCではDeveloper PowerShellなどの開発者シェル、MinGW64とUCRT64では対応するMSYS2
シェルから実行してください。

インストール後のスクリプトは、MSVC用の`/MD`版と`/MT`版を両方ダウンロードします。
通常のCrystalビルドでは`/MD`、`--static`を指定したビルドでは`/MT`が使われます。

### コンソールウィンドウを表示しない

WindowsでビルドしたGUI実行ファイルは、コンソールウィンドウを開く場合があります。
配布用の実行ファイルではWindows GUIサブシステムを指定します。

MinGW64またはUCRT64:

<pre><code class="bash">
crystal build app.cr --link-flags "-mwindows"
</code></pre>

MSVC:

<pre><code class="powershell">
crystal build app.cr --link-flags=/SUBSYSTEM:WINDOWS
</code></pre>

## インストールを確認する

`hello.cr`を作成します。

<pre><code class="crystal">
require "uing"

UIng.init

window = UIng::Window.new("Hello World", 300, 200)
window.on_closing do
  UIng.quit
  true
end

window.child = UIng::Label.new("Hello from UIng")
window.show

UIng.main
UIng.uninit
</code></pre>

次のコマンドで実行します。

<pre><code class="bash">
crystal run hello.cr
</code></pre>

「Hello World」というタイトルのネイティブウィンドウが開けば成功です。
[最初のアプリケーション](first-steps.md)へ進み、ボタンとイベントを扱ってみましょう。
