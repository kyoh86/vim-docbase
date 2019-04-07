# vim-docbase

DocBaseをVimで編集できるようにするプラグイン。

## コマンド

* `:DocBaseList [domain]`

指定されたドメインのDocBaseのメモ一覧を取得して表示する。
ドメイン設定が一つしかない場合はdomainの指定を省略できる。
一覧は専用バッファに表示される。

## 設定項目

`g:docbase` : 以下キーを持つdict。または同dictのリスト
    * domain
    * token

例:

```
g:docbase = { 'domain': 'example', 'token': '1b_z85n.83hrwefsv9cxm8ihwaemsv9p283rih' }
```

```
g:docbase = [
  \ { 'domain': 'example', 'token': '1b_z85n.83hrwefsv9cxm8ihwaemsv9p283rih' },
  \ { 'domain': 'sample', 'token': '1f_a89x.oo08yudfsjawofaj8hiqwnskljweiu' }
  \ ]
```
