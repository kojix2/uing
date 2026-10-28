# 開発

[English](../guide_en/development.html)

UIngは、Crystalでネイティブアプリケーションを構築するための、小さく持続可能な基盤です。
変更を加えるときは、安定性、クロスプラットフォームの動作、既存のライフタイム規則を
維持してください。

## APIレベル

<table>
  <thead>
    <tr><th>レベル</th><th>定義場所</th><th>例</th><th>用途</th></tr>
  </thead>
  <tbody>
    <tr><td>高レベル</td><td><code>src/uing/*.cr</code></td><td><code>button.on_clicked { }</code></td><td>オブジェクト指向のアプリケーションAPI</td></tr>
    <tr><td>低レベル</td><td><code>src/uing/lib_ui/lib_ui.cr</code></td><td><code>UIng::LibUI.new_button</code></td><td>libui-ngへの直接バインディング</td></tr>
  </tbody>
</table>

高レベルAPIは`Window`、`Label`、`Button`などの基本コントロールに加え、`Table`や
`Area`などの高度なコントロールも提供します。通常のアプリケーションコードでは
こちらを使います。`UIng::LibUI`は、基盤となるC APIへの直接アクセスと、高レベル
ラッパーの実装に使用します。

## 低レベルバインディングとネイティブライブラリ

低レベルバインディングは、当初
[crystal_lib](https://github.com/crystal-lang/crystal_lib)で生成していました。
生成後にも`LibC::Int`から高レベルの`Bool`への変換など、多くの手動調整が必要だったため、
現在はAIの支援も利用しながら直接保守しています。

コンポーネントを追加するときは、既存コントロールのコールバックとライフタイムの
パターンに従います。ネイティブのlibui-ngは
[kojix2/libui-ng](https://github.com/kojix2/libui-ng)のGitHub Actionsでビルドされ、
UIng固有の拡張は`dev`ブランチで保守されます。Windowsでは`comctl32.manifest`により
Common Controls v6を選択し、OS標準コントロールに新しい視覚スタイルを適用します。

## メモリ安全性

- レジストリと親への参照で、ネイティブ側の破棄までラッパーを保持します。
- AreaとTable::ModelがHandlerを、Handlerがクロージャと捕捉したCrystalオブジェクトを
  保持します。捕捉したネイティブ資源は使用中、有効に保ってください。
- 通常のコールバックは`data`からBox化したクロージャを復元します。AreaとTableモデルは
  公開`UserData`フィールド（LibUIでは`user_data`）からHandlerを復元します。
- 借用されたコールバック値は、コールバック終了時に無効化されます。

LibUIを直接使う場合は、ハンドラとコールバック用データを利用者側で保持します。
ネイティブライブラリはFFIレイアウトと一致させ、`download.cr`のリリースとチェックサムを
合わせて更新してください。解放規則は[ランタイムとライフタイム](runtime-and-lifetime.md)を参照してください。

## 生成AIの利用

GitHub Actions、複雑なサンプル、メモリ安全性のレビュー、パッチ適用版libui-ngの開発に
生成AIを利用しています。UIngは反復的な実装と、生成コードに対する人間の行単位レビュー
から始まりました。現在の人間の作業は、全体設計、ネイティブGUIの目視確認、実際の利用を
通じた改善点の発見に重点を置いています。

## コントリビューション

- リポジトリをforkしてPull Requestを送ってください。
- 再現手順、プラットフォーム、Crystalのバージョンを添えてバグを報告してください。
- 表示動作を変更するときは、クロスプラットフォームのサンプルも追加・更新してください。
- UIngに関する記事や利用報告も歓迎します。
