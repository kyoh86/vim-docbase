let s:V = vital#docbase#new()
call s:V.load('Data.String')
call s:V.load('Data.Dict')

let s:urn = {}

" docbase プラグインで利用する URN は次のような構成になる
"
" docbase:[DOMAIN[:post-id]]
"
" このクラスでURNをパースして、適切な処理への割当を行えるようにする
" 処理の割当はmetarw#docbase#(read|write)でreader()/writer()を利用する
function! docbase#urn#parse(str) abort
  let l:parts = s:V.Data.String.nsplit(a:str, 2, '?')
  let l:paramlist = split(get(l:parts, 1, ''), '[&=]')
  let l:params = s:V.Data.Dict.from_list(l:paramlist)

  let l:parts = s:V.Data.String.nsplit(l:parts[0], 3, ':')
  let l:urn = deepcopy(s:urn)
  let l:urn.scheme = get(l:parts, 0, '')
  let l:urn.domain = get(l:parts, 1, '')
  let l:urn.id     = get(l:parts, 2, '')
  let l:urn.params = l:params
  call l:urn.validate()
  return l:urn
endfunction

" ファイルタイプを判定する
function! s:urn.filetype() abort
  if self.domain ==# '' || self.id ==# ''
    return 'docbase-list'
  endif

  return 'docbase'
endfunction

" 次の階層に指定のIDを指定したURNを返す
function! s:urn.digg(next_level) abort
  let l:digged = deepcopy(self)
  let l:key = ''
  if self.domain ==# ''
    let l:key = 'domain'
  elseif self.id ==# ''
    let l:key = 'id'
  endif

  if l:key !=# ''
    let l:digged[l:key] = a:next_level
    let l:digged.params = {}
  endif

  return l:digged
endfunction

function! s:urn.page(...) abort
  let l:page = get(self.params, 'page', 0)
  if l:page == 0 && len(a:000) > 0
    let l:page = a:0
    let self.params.page = l:page
  endif
  return l:page
endfunction

function! s:urn.next_page() abort
  let l:page = self.page(1)
  let l:next = deepcopy(self)
  let l:next.params.page = l:page + 1
  return l:next
endfunction

function! s:urn.prev_page() abort
  let l:page = self.page(1)
  let l:next = deepcopy(self)
  let l:next.params.page = l:page - 1
  return l:next
endfunction

function! s:urn.string() abort
  call self.validate()

  let l:str = join(
    \ filter(
      \ [
        \ self.scheme,
        \ self.domain,
        \ self.id
      \ ],
    \ { _, v -> v !=# '' })
  \ , ':')
  if len(self.params) > 0
    let l:glue = '?'
    for l:key in keys(self.params)
      let l:str .= l:glue . l:key . '=' . self.params[l:key]
      let l:glue = '&'
    endfor
  endif
  return l:str
endfunction

" Function: urn.reader : 指定されたURNの内容を読みこむ処理へのマッピングを行う
" | urn                  | function             |
" | --------------------- | -------------------- |
" | docbase:              | docbase#root#domains |
" | docbase:domain        | docbase#post#list    |
" | docbase:domain:000000 | docbase#post#read    |
" | docbase:domain:new    | docbase#post#new     |
" TODO : docbase:domain:post:search : 検索
function! s:urn.reader() abort
  if self.domain ==# ''
    return function('docbase#root#domains')
  endif

  if self.id ==# ''
    return function('docbase#post#list')
  endif

  if self.id ==# 'new'
    return function('docbase#post#new')
  endif

  return function('docbase#post#read')
endfunction

" Function: urn.writer : 指定されたURNへの書き込む処理へのマッピングを行う
" | urn                  | function            |
" | --------------------- | ------------------- |
" | docbase:              | invalid             |
" | docbase:domain        | invalid             |
" | docbase:domain:000000 | docbase#post#write  |
" | docbase:domain:new    | docbase#post#create |
function! s:urn.writer() abort
  if self.domain ==# '' ||  self.id ==# ''
    return function('<SID>invalid')
  endif

  if self.id ==# 'new'
    return function('docbase#post#create')
  endif

  return function('docbase#post#write')
endfunction

function! s:invalid()
  throw 'invalid operation' 
endfunction

function! s:urn.validate()
  if self.id !=# '' && self.domain ==# ''
    throw "there's no domain"
  endif
endfunction
