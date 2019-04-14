let s:V = vital#docbase#new()
call s:V.load('Data.String')
call s:V.load('Data.Dict')

let s:path = {}

function! docbase#path#parse(str) abort
  let l:parts = s:V.Data.String.nsplit(a:str, 2, '?')
  let l:paramlist = split(get(l:parts, 1, ''), '[&=]')
  let l:params = s:V.Data.Dict.from_list(l:paramlist)

  let l:parts = s:V.Data.String.nsplit(l:parts[0], 4, ':')
  let l:path = deepcopy(s:path)
  let l:path.scheme = get(l:parts, 0, '')
  let l:path.domain = get(l:parts, 1, '')
  let l:path.object = get(l:parts, 2, '')
  let l:path.id     = get(l:parts, 3, '')
  let l:path.params = l:params
  call l:path.validate()
  return l:path
endfunction

function! s:path.digg(next_level) abort
  let l:digged = deepcopy(self)
  let l:key = ''
  if self.domain ==# ''
    let l:key = 'domain'
  elseif self.object ==# ''
    let l:key = 'object'
  elseif self.id ==# ''
    let l:key = 'id'
  endif

  if l:key !=# ''
    let l:digged[l:key] = a:next_level
    if has_key(l:digged.params, 'page')
      call remove(l:digged.params, 'page')
    endif
  endif

  return l:digged
endfunction

function! s:path.page(...) abort
  let l:page = get(self.params, 'page', 0)
  if l:page == 0 && len(a:000) > 0
    let l:page = a:0
    let self.params.page = l:page
  endif
  return l:page
endfunction

function! s:path.next_page() abort
  let l:page = self.page(1)
  let l:next = deepcopy(self)
  let l:next.params.page = l:page + 1
  return l:next
endfunction

function! s:path.prev_page() abort
  let l:page = self.page(1)
  let l:next = deepcopy(self)
  let l:next.params.page = l:page - 1
  return l:next
endfunction

function! s:path.string() abort
  call self.validate()
  let l:main = join(
    \ filter(
      \ [
        \ self.scheme,
        \ self.domain,
        \ self.object,
        \ self.id
      \ ],
    \ { _, v -> v !=# '' })
  \ , ':')
  if len(self.params) > 0
    let l:glue = '?'
    for l:key in keys(self.params)
      let l:main .= l:glue . l:key . '=' . self.params[l:key]
      let l:glue = '&'
    endfor
  endif
  return l:main
endfunction

" Function: path.reader : 指定されたURNの内容を読みこむ処理へのマッピングを行う
" | path                         | function             |
" | ---------------------------- | -------------------- |
" | docbase:                     | docbase#root#domains |
" | docbase:domain               | docbase#root#objects |
" | docbase:domain:object        | docbase#object#list  |
" | docbase:domain:object:000000 | docbase#object#read  |
" | docbase:domain:object:new    | docbase#object#new   |
" TODO : docbase:domain:object:search : 検索
function! s:path.reader() abort
  if self.domain ==# ''
    return function('docbase#root#domains')
  endif

  if self.object ==# ''
    return function('docbase#root#objects')
  endif

  if self.id ==# ''
    return function('docbase#' . self.object . '#list')
  endif

  if self.id ==# 'new'
    return function('docbase#' . self.object . '#new')
  endif

  return function('docbase#' . self.object . '#read')
endfunction

" Function: path.writer : 指定されたURNへの書き込む処理へのマッピングを行う
" | path                         | function              |
" | ---------------------------- | --------------------- |
" | docbase:                     | invalid               |
" | docbase:domain               | invalid               |
" | docbase:domain:object        | invalid               |
" | docbase:domain:object:000000 | docbase#object#write  |
" | docbase:domain:object:new    | docbase#object#create |
function! s:path.writer() abort
  if self.domain ==# '' || self.object ==# '' || self.id ==# ''
    return function('<SID>invalid')
  endif

  if self.id ==# 'new'
    return function('docbase#' . self.object . '#create')
  endif

  return function('docbase#' . self.object . '#write')
endfunction

function! s:path.client()
  let l:domain = get(self, 'domain', '')
  if l:domain ==# ''
    throw 'invalid operation: it is tried to creating api client without domain'
  endif

  let l:cache = get(get(self, 'api', {}), l:domain, v:null)
  if l:cache != v:null
    return l:cache
  endif

  let l:docbase = copy(get(g:, 'docbase', []))

  let l:options = filter(l:docbase, { _, opt -> get(opt, 'domain', '') ==# l:domain })
  if len(l:options) == 0
    throw 'g:docbase has no option for "' . l:domain . '"'
  endif
  let l:option = l:options[0]

  if !has_key(l:option, 'domain')
    throw 'g:docbase has no domain option'
  elseif !has_key(l:option, 'token')
    throw 'g:docbase has no token option'
  endif

  let l:api = docbase#api#new(l:option.domain, l:option.token)
  let self.api = {}
  let self.api[self.domain] = l:api
  return self.api[self.domain]
endfunction

function! s:invalid()
  throw 'invalid operation' 
endfunction

function! s:path.validate()
  if self.scheme !=# 'docbase'
    throw 'invalid scheme for docbase reader'
  endif

  if self.id !=# '' && self.object ==# ''
    throw 'invalid object for docbase path'
  endif

  if ( self.id !=# '' || self.object !=# '' ) && self.domain ==# ''
    throw "there's no domain"
  endif
endfunction
