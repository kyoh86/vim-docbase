# vim-docbase

DocBaseをVimで編集できるようにするプラグイン。

## 必要な依存プラグイン

* [vim-metarw](https://github.com/kana/vim-metarw)

## 設定項目

`g:docbase` : 以下キーを持つdictのリスト

* domain
* token

例:

```
g:docbase = [
  \ { 'domain': 'example', 'token': '1b_z85n.83hrwefsv9cxm8ihwaemsv9p283rih' },
  \ { 'domain': 'sample', 'token': '1f_a89x.oo08yudfsjawofaj8hiqwnskljweiu' }
  \ ]
```

### 注意

**tokenを含むこれらの設定を `vimrc` に書く場合、dotfilesなどにアップロードしないこと**

## 編集方法

* `:e docbase:`
  * 設定されたドメインの一覧を表示する。Enterでドメインを選択。
* `:e docbase:[domain]:`
  * 指定したドメインの編集可能なオブジェクトの一覧を表示する。Enterでオブジェクトを選択。
* `:e docbase:[domain]:post:`
  * 指定したドメインの投稿の一覧を表示する。Enterで投稿の編集画面に入る。

# LICENSE

[![MIT License](http://img.shields.io/badge/license-MIT-blue.svg)](http://www.opensource.org/licenses/MIT)

This software is released under the [MIT License](http://www.opensource.org/licenses/MIT), see LICENSE.
