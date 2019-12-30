 vim-docbase

DocBase APIをVimから利用するためのプラグインです。

## 関連プラグイン

* [vim-metarw-docbase](https://github.com/kyoh86/vim-metarw-docbase)
    * DocBaseをVimで編集するためのプラグイン

## 設定項目

`g:docbase` : 以下のように、domainとtokenの組み合わせを設定してください。

```vim
let g:docbase = {
              \   'domains': [{
              \     'domain': 'DOMAIN',
              \     'token': 'TOKEN'
              \   }, {
                ...
              \   }]
              \ }
```

**tokenを含むこれらの設定を `vimrc` に書く場合、dotfilesなどにアップロードしないよう注意してください**

## 利用できる関数

| Service | Function | Implemented |
| --- | --- | --- | --- |
| Post | List | ☑ |
| Post | Create | ☑ |
| Post | Get | ☑ |
| Post | Edit | ☑ |
| Post | Archive | ☐ |
| Post | Unarchive | ☐ |
| Post | Delete | ☐ |
| User | List | ☐ |
| Comment | Create | ☐ |
| Comment | Delete | ☐ |
| Attachment | Upload | ☐ |
| Tag | List | ☐ |
| Group | Create | ☐ |
| Group | Get | ☐ |
| Group | List | ☐ |
| Group | AddUsers | ☐ |
| Group | RemoveUsers | ☐ |

# LICENSE

[![MIT License](http://img.shields.io/badge/license-MIT-blue.svg)](http://www.opensource.org/licenses/MIT)

This software is released under the [MIT License](http://www.opensource.org/licenses/MIT), see LICENSE.
