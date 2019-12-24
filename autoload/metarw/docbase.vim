scriptencoding utf-8

"
" Author: kyoh86
" License: MIT

" This function will be called by vim-metarw (https://github.com/kana/vim-metarw)
" If you want to ref metarw help: `:help metarw-schemes`
"
" Function: metarw#docbase#read({fakepath})
" Arg:
"   - fakepath for docbase docbase:[<domain>[:<post-id>]]
function! metarw#docbase#read(fakepath) abort
  let l:urn = docbase#urn#parse(a:fakepath)
  let b:docbase_urn = l:urn
  "
  " | urn                  | function                  |
  " | --------------------- | ------------------------ |
  " | docbase:              | s:domains()              |
  " | docbase:domain:?      | metarw#docbase#post#list |
  " | docbase:domain:000000 | metarw#docbase#post#read |
  " | docbase:domain:new    | metarw#docbase#post#new  |
  " UNDONE: docbase:domain:post:search : 検索
  if l:urn.domain ==# ''
    return ['browse', s:domains()]
  endif
 
  if l:urn.id ==# ''
    return ['browse', metarw#docbase#post#list(l:urn.domain)]
  endif

  if l:urn.id ==# 'new'
    return ['read', function('metarw#docbase#post#new', [l:urn])]
  endif

  return ['read', function('metarw#docbase#post#read', [l:urn])]
endfunction

" This function will be called by vim-metarw (https://github.com/kana/vim-metarw)
" If you want to ref metarw help: `:help metarw-schemes`
"
" Function: metarw#docbase#write({fakepath}, {line1}, {line2}, {append_p})
" Arg:
"   - fakepath for docbase docbase:[<domain>[:<post-id>]]
"   - line1 will be ignored
"   - line2 will be ignored
"   - append_p will be ignored
function! metarw#docbase#write(fakepath, line1, line2, append_p) abort
  let l:urn = docbase#urn#parse(a:fakepath)
  " | urn                  | function                    |
  " | --------------------- | -------------------------- |
  " | docbase:              | invalid                    |
  " | docbase:domain:?      | invalid                    |
  " | docbase:domain:000000 | metarw#docbase#post#write  |
  " | docbase:domain:new    | metarw#docbase#post#create |
  if l:urn.domain ==# '' ||  l:urn.id ==# ''
    throw 'invalid operation' 
  endif

  if l:urn.id ==# 'new'
    return ['write', function('metarw#docbase#post#create', [l:urn])]
  endif

  return ['write', function('metarw#docbase#post#write', [l:urn])]
endfunction

" This function will be called by vim-metarw (https://github.com/kana/vim-metarw)
" If you want to ref metarw help: `:help metarw-schemes`
"
" Function: metarw#docbase#complete({arg_lead}, {cmdline}, {cursor_pos})
" Arg:
"   - arg_lead: the leading portion of the argument currently being completed on
"   - cmdline: the entire command line
"   - cursor_pos: the cursor position in it (byte index)
"
"   - {arg_lead} is split into "head" part and "tail" part.
"     They must fulfill the following equation:
"     {arg_lead} ==# head_part . tail_part
"   - This function must complete candidates which are
"     conteind in a stuff represented by the "head" part.
"   - Return value is a list with 3 items.
"     The first item is a list of candidates.
"     The second item is the "head" part.
"     The third item is the "tail" part.
"   - Returned candidates will be filtered by callers.  So
"     don't filter in this function.
"
"   For example, when completing file names and {arg_lead}
"   is "foo/b":
"   - The "head" part is "foo/".
"   - The "tail" part is "b".
"   - This function must complete files in the directory
"     "foo/".
function! metarw#docbase#complete(arg_lead, cmdline, cursor_pos)
  let l:urn = docbase#urn#parse(a:arg_lead)

" | arg_lead                   | level | returns                                            |
" | -------------------------- | ----- | -------------------------------------------------- |
" | docbase:                   | 2     | [[domains...], 'docbase:', '']                     |
" | docbase:frag               | 2     | [[domains...], 'docbase:', 'frag']                 |
" | docbase:domain:            | 3     | [[post_ids...], 'docbase:domain:', '']             |
" | docbase:domain:[1-9][0-9]* | 3     | [[post_ids...], 'docbase:domain:', '[1-9][0-9]*']  |
" | docbase:domain:n(ew?)?     | 3     | [['new'], 'docbase:domain:', 'n(ew?)?']            |
  if l:urn.level == 2
    return [map(docbase#config#domain_names(), {_, d -> 'docbase:' . d . ':'}), 'docbase:', l:urn.domain]
  elseif l:urn.level == 3
    if l:urn.id ==# ''
      return [['docbase:' . l:urn.domain . ':new'] + metarw#docbase#post#list_urn(l:urn.domain), 'docbase:' . l:urn.domain . ':', l:urn.id]
    elseif l:urn.id =~ '^[1-9]'
      return [metarw#docbase#post#list_urn(l:urn.domain), 'docbase:' . l:urn.domain . ':', l:urn.id]
    else
      return [['docbase:' . l:urn.domain . ':new'], 'docbase:' . l:urn.domain . ':', l:urn.id]
    endif
  else
    return [[], a:arg_lead, '']
  endif
endfunction

function! s:domains()
  let l:domains = docbase#config#domain_names()
  call map(l:domains, { _, domain -> { 'label': domain, 'fakepath': 'docbase:' . domain } })

  return l:domains
endfunction
