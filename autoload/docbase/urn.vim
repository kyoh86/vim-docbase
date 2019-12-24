let s:V = vital#docbase#new()
call s:V.load('Data.String')
call s:V.load('Data.Dict')

let s:urn = {}


" Function: URNをパースする
" docbase プラグインで利用する URN は次のような構成になる
"
" docbase:[DOMAIN[:post-id]]
function! docbase#urn#parse(str) abort
  let l:parts = split(a:str, ':', v:true)
  let l:urn = deepcopy(s:urn)
  let l:urn.scheme = get(l:parts, 0, '')
  let l:urn.domain = get(l:parts, 1, '')
  let l:urn.id     = get(l:parts, 2, '')
  let l:urn.level = len(l:parts)
  call l:urn.validate()
  return l:urn
endfunction

" ファイルタイプを判定する
function! s:urn.filetype() abort
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
  return l:str
endfunction

function! s:urn.validate()
  if self.id !=# '' && self.domain ==# ''
    throw "there's no domain"
  endif
endfunction
