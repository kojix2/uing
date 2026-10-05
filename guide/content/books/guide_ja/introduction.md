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

コントロールギャラリーの実行例です。同じコードが各プラットフォームの
ネイティブな外観で動作します。

<div class="widget-screenshots">
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/control_gallery-ubuntu.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/control_gallery-ubuntu.png" alt="Control gallery on Ubuntu" loading="lazy"></a><figcaption>Ubuntu</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/control_gallery-windows.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/control_gallery-windows.png" alt="Control gallery on Windows" loading="lazy"></a><figcaption>Windows</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/control_gallery-macos.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/control_gallery-macos.png" alt="Control gallery on macOS" loading="lazy"></a><figcaption>macOS</figcaption></figure>
</div>

このガイドでは、アプリケーションを作成するために必要な基本概念に絞って説明します。
インターフェースの書き方には通常のAPIとブロックベースのDSLの2つがあります。詳しくは
[コーディングスタイル](coding-styles.md)を参照してください。
型とメソッドの完全な一覧は[APIリファレンス](../../api/)を参照してください。
