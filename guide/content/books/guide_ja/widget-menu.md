# Menu

[English](../guide_en/widget-menu.html)

MenuはアプリケーションメニューとOS標準のメニュー項目を作成します。

## 表示例

<div class="widget-screenshots">
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_menu-ubuntu.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_menu-ubuntu.png" alt="Menu on Ubuntu" loading="lazy"></a><figcaption>Ubuntu</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_menu-windows.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_menu-windows.png" alt="Menu on Windows" loading="lazy"></a><figcaption>Windows</figcaption></figure>
  <figure><a href="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_menu-macos.png"><img src="https://raw.githubusercontent.com/kojix2/uing/screenshots/basic_menu-macos.png" alt="Menu on macOS" loading="lazy"></a><figcaption>macOS</figcaption></figure>
</div>

## 実行例

{{% shell command="sh scripts/render-example basic_menu" %}}

## 使い方

- メニュー項目には次の種類があります。

  | 種類 | 作成メソッド | 用途 |
  | --- | --- | --- |
  | 通常項目 | <code>append_item(name)</code> | コマンドを実行します。 |
  | チェック項目 | <code>append_check_item(name, checked:)</code> | オン／オフの状態を表します。<code>checked?</code>と<code>checked=</code>で状態を読み書きできます。 |
  | Preferences項目 | <code>append_preferences_item</code> | 設定画面を開きます。 |
  | About項目 | <code>append_about_item</code> | アプリケーション情報を表示します。 |
  | Quit項目 | <code>append_quit_item</code> | アプリケーションを終了します。終了処理は<code>UIng.on_should_quit</code>で設定します。 |
  | 区切り | <code>append_separator</code> | 関連する項目のグループを視覚的に分けます。 |

- 最初のWindowを作る前にすべてのMenuを構築し、Windowへ<code>menubar: true</code>を指定します。
- 最初のWindowを作る前に`item.set_shortcut('O', UIng::Modifiers::Primary)`でショートカットを設定できます。`Primary`はmacOSではCommand、Windows/LinuxではControlです。解除には`item.clear_shortcut`を使います。
- キーにはASCIIの英字・数字、`UIng::ExtKey::F1`～`F12`、`Delete`、矢印キーを指定できます。F1～F12以外には`Primary`、`Ctrl`、`Alt`のいずれかが必要で、`Shift`を追加できます。`Super`、`Primary | Ctrl`、重複するショートカットは使用できません。
- プラットフォーム側の操作ではWindowがない場合があるため、コールバックには省略可能なWindowが渡されます。
- `item.clear_on_clicked`は`item.on_clicked(nil)`と同じです。クリック時のコールバックを解放し、項目は引き続き使用できます。どちらもメニューから項目を削除しません。Quit項目には代わりに`UIng.clear_on_should_quit`を使います。
- <code>Preferences</code>、<code>About</code>、<code>Quit</code>はOSごとのメニュー規約を吸収する標準項目です。表示名、配置、区切り線はOSによって異なり、追加したMenu内の順序どおりに表示されるとは限りません。
- <code>append_preferences_item</code>、<code>append_about_item</code>、<code>append_quit_item</code>は、それぞれアプリケーション全体で1つだけ追加できます。



[APIリファレンス](../../api/UIng/Menu.html) · [Galleryソース](https://github.com/kojix2/uing/blob/main/examples/gallery/basic_menu.cr)
