# サンプルとAPIリファレンス

[English](../guide_en/examples-and-api.html)

まずガイドでアプリケーションの構造を学び、公開されている型とメソッドの完全な一覧は
APIリファレンスで確認してください。

- [APIリファレンス](../../api/)
- [コントロールギャラリー](https://github.com/kojix2/uing/tree/main/examples/gallery)
- [UIngソースコード](https://github.com/kojix2/uing)
- [libui-ng](https://github.com/kojix2/libui-ng)

## 実行可能なサンプル

ギャラリーには、個々のコントロール、コンテナ、メニュー、テーブル、カスタム描画に
焦点を当てたサンプルがあります。リポジトリをcloneして開発用依存関係を導入し、
次のコマンドでギャラリー全体を実行できます。

<pre><code class="bash">
git clone https://github.com/kojix2/uing
cd uing
shards install
crystal run examples/crimage/control_gallery.cr
</code></pre>

より大きなサンプルには次のものがあります。

- [MD5 Checker](https://github.com/kojix2/uing/tree/main/examples/md5_checker)
- [Video Player](https://github.com/kojix2/uing/tree/main/examples/video_player)
- [Air Hockey](https://github.com/kojix2/uing/tree/main/examples/air_hockey)

必要なコントロールを含む最小のサンプルから始めてください。カスタム描画とテーブルには
追加のコールバックとライフタイム規則があるため、ギャラリーのサンプルが最適な出発点です。

## アプリケーションのパッケージング

[MD5 Checker](https://github.com/kojix2/uing/tree/main/examples/md5_checker)には、
UIngアプリケーションと必要なネイティブライブラリをLinux、macOS、Windows向けに
パッケージングするスクリプトがあります。アプリケーションを配布するときの
出発点として利用できます。
