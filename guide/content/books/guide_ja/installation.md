# インストール

[English](../guide_en/installation.html)

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
ダウンロードします。`shard.yml`と`shard.lock`はコミットしますが、ダウンロードされた
`libui`ディレクトリはコミットしないでください。

## プラットフォームごとの注意事項

### Linux

アプリケーションをビルドする前にGTK 3の開発パッケージをインストールしてください。
パッケージ名はディストリビューションによって異なります。DebianとUbuntuでは
`libgtk-3-dev`です。

### macOS

ネイティブGUIの依存関係には、システムのAppKitフレームワークを使用します。
Intel MacとApple Siliconの両方に対応しています。

### Windows

UIngはMSVC、MinGW64、UCRT64に対応しています。MSVCでビルドする場合は、コンパイラと
Windows SDKを利用できるよう、x64 Native ToolsコマンドプロンプトまたはDeveloper
PowerShellからCrystalを実行してください。

## インストールを確認する

`hello.cr`を作成します。

<pre><code class="crystal">
require "uing"

puts UIng::VERSION
</code></pre>

次のコマンドで実行します。

<pre><code class="bash">
crystal run hello.cr
</code></pre>

インストールされたUIngのバージョンが表示されれば成功です。
[最初のアプリケーション](first-steps.md)へ進み、ネイティブウィンドウを開いてみましょう。
