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

  let l:parts = split(l:parts[0], ':', v:true)
  let l:urn = deepcopy(s:urn)
  let l:urn.scheme = get(l:parts, 0, '')
  let l:urn.domain = get(l:parts, 1, '')
  let l:urn.id     = get(l:parts, 2, '')
  let l:urn.params = l:params
  let l:urn.level = len(l:parts)
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
function! s:urn.digg(digg_id) abort
  let l:digged = deepcopy(self)
  let l:key = ''
  if self.domain ==# ''
    let l:key = 'domain'
  elseif self.id ==# ''
    let l:key = 'id'
  endif

  if l:key !=# ''
    let l:digged[l:key] = a:digg_id
    let l:digged.params = {}
    let l:digged.level = 3
  endif

  return l:digged
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

" Function: urn.read : 指定されたURNの内容を読みこむ
" | urn                  | function             |
" | --------------------- | -------------------- |
" | docbase:              | docbase#root#domains |
" | docbase:domain        | docbase#post#list    |
" | docbase:domain:000000 | docbase#post#read    |
" | docbase:domain:new    | docbase#post#new     |
" TODO : docbase:domain:post:search : 検索
function! s:urn.read() abort
  if self.domain ==# ''
    return ['browse', docbase#root#domains(self)]
  endif
 
  if self.id ==# ''
    return ['browse', docbase#post#list(self)]
  endif

  if self.id ==# 'new'
    return ['read', function('docbase#post#new', [self])]
  endif

  return ['read', function('docbase#post#read', [self])]
endfunction

" Function: urn.write : 指定されたURNへの書き込む処理へのマッピングを行う
" | urn                  | function            |
" | --------------------- | ------------------- |
" | docbase:              | invalid             |
" | docbase:domain        | invalid             |
" | docbase:domain:000000 | docbase#post#write  |
" | docbase:domain:new    | docbase#post#create |
function! s:urn.write() abort
  if self.domain ==# '' ||  self.id ==# ''
    return function('<SID>invalid')
  endif

  if self.id ==# 'new'
    return docbase#post#create(self)
  endif

  return docbase#post#write(self)
endfunction

" Function: urn.complete : 指定されたURNの補完を提供する
" | urn                        | level | returns                                            |
" | -------------------------- | ----- | -------------------------------------------------- |
" | docbase:                   | 2     | [[domains...], 'docbase:', '']                     |
" | docbase:frag               | 2     | [[domains...], 'docbase:', 'frag']                 |
" | docbase:domain:            | 3     | [[post_ids...], 'docbase:domain:', '']             |
" | docbase:domain:[1-9][0-9]* | 3     | [[post_ids...], 'docbase:domain:', '[1-9][0-9]*']  |
" | docbase:domain:n(ew?)?     | 3     | [['new'], 'docbase:domain:', 'n(ew?)?']            |
function! s:urn.complete(arg_lead, cmdline, cursor_pos) abort
  echom 'lev: ' . self.level
  if self.level == 2
    return [map(docbase#config#domain_names(), {_, d -> 'docbase:' . d}), 'docbase:', self.domain]
  elseif self.level == 3
    if self.id ==# ''
      return [['docbase:' . self.domain . ':new'] + docbase#post#list_urns(self), 'docbase:' . self.domain . ':', self.id]
    elseif self.id =~ '^[1-9]'
      return [docbase#post#list_urns(self), 'docbase:' . self.domain . ':', self.id]
    else
      return [['docbase:' . self.domain . ':new'], 'docbase:' . self.domain . ':', self.id]
    endif
  else
    return [[], a:arg_lead, '']
  endif
endfunction

function! s:invalid()
  throw 'invalid operation' 
endfunction

function! s:urn.validate()
  if self.id !=# '' && self.domain ==# ''
    throw "there's no domain"
  endif
endfunction
