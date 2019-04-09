let s:V = vital#docbase#new()
call s:V.load('Web.HTTP')

let s:baseUrl = 'https://api.docbase.io'

let s:api = {}
let s:post = {}

function! s:api.post()
  let service = deepcopy(s:post)
  let service.root = self
  return service
endfunction

" Function: メモの検索
" Description: 指定したドメインのチームのメモを検索し、メモの一覧を取得します。
" Arguments:
"   - params: リクエストパラメータ
"     | パラメータ | 内容             | 必須 | デフォルト値 | 最大値 |
"     | ---------- | ---------------- | ---- | ------------ | ------ |
"     | q          | 検索文字列       |      | *            |        |
"     | page       | ページ           |      | 1            |        |
"     | per_page   | ページ枚のメモ数 |      | 20           | 100    |
function! s:post.list(params)
  return self.root.get('/posts', a:params).posts
endfunction

" Function: メモの詳細取得
" Description: 指定したドメインのチームのメモのIDを指定して情報を取得します。
" Arguments:
"   - post_id: メモのID
function! s:post.get(post_id)
  return self.root.get('/posts/' . a:post_id, {})
endfunction

" Function: メモの更新
" Description: 指定したドメインのチームの、指定したメモを更新します。
" Arguments:
"   - post_id: メモのID
"   - content: 更新内容
"     | パラメータ | 内容                     | 型            | 必須                     | デフォルト値 |
"     | ---------- | ------------------------ | ------------- | ------------------------ | ------------ |
"     | title      | メモのタイトル           | String        |                          |              |
"     | body       | メモの本文               | String        |                          |              |
"     | draft      | 下書き保存にするかどうか | Boolean       |                          |              |
"     | notice     | 通知するかどうか         | Boolean       |                          | true         |
"     | tags       | タグ名の配列             | String Array  |                          |              |
"     | scope      | 公開範囲                 | String        |                          |              |
"     | groups     | グループID配列           | Integer Array | scopeがgroupの時のみ必須 |              |
function! s:post.update(post_id, content)
  return self.root.patch('/posts/' . a:post_id, a:content)
endfunction

function! s:api.header()
  return {'Content-type': 'application/json', 'X-DocBaseToken': self.token}
endfunction

function! s:api.teamUrl(path)
  return s:baseUrl . '/teams/' . self.domain . a:path
endfunction

function! s:api.get(path, param)
  let l:response = s:V.Web.HTTP.get(self.teamUrl(a:path), a:param, self.header())
  if l:response.status != 200
    throw printf('failed to docbase.get (%d: %s)', l:response.status, l:response.content)
  endif
  return json_decode(l:response.content)
endfunction

function! s:api.patch(path, body)
  let l:response = s:V.Web.HTTP.request(
    \ 'PATCH',
    \ self.teamUrl(a:path),
    \ {
      \ 'data': json_encode(a:body),
      \ 'headers': self.header()
    \ }
  \ )
  if l:response.status != 200
    throw printf('failed to docbase.patch (%d: %s)', l:response.status, l:response.content)
  endif
  return json_decode(l:response.content)
endfunction

function! docbase#api#new(domain, token)
  let client = deepcopy(s:api)
  let client.domain = a:domain
  let client.token = a:token
  return client
endfunction

