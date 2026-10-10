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

[基本的なウィンドウの作例](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_window.cr)です。
同じコードが各プラットフォームのネイティブな外観で動作します。

<div class="widget-screenshots">
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_window-ubuntu.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_window-ubuntu.png" alt="基本的なウィンドウ（Ubuntu）" loading="lazy"></a><figcaption>Ubuntu</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_window-windows.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_window-windows.png" alt="基本的なウィンドウ（Windows）" loading="lazy"></a><figcaption>Windows</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_window-macos.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_window-macos.png" alt="基本的なウィンドウ（macOS）" loading="lazy"></a><figcaption>macOS</figcaption></figure>
</div>

このガイドでは、アプリケーションを作成するために必要な基本概念に絞って説明します。
インターフェースの書き方には通常のAPIとブロックベースのDSLの2つがあります。詳しくは
[コーディングスタイル](coding-styles.md)を参照してください。
型とメソッドの完全な一覧は[APIリファレンス](../../api/)を参照してください。

## プロジェクトの方針

UIngは、シンプルなネイティブGUIを構築するための、小さく持続可能な基盤を目指します。
多機能なGUIフレームワークへ拡大することよりも、長期にわたって安定し、保守しやすい状態を
維持することを優先します。

## 制約事項

- レイアウトにはOS標準のコンテナを使用します。コントロールを任意のピクセル座標へ
  配置することはできませんが、各プラットフォームでネイティブな外観を保ちやすくなります。
- Tableへ追加した列を後から削除することはできません。
