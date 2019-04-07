let s:V = vital#docbase#new()
call s:V.load('Data.String')

function! docbase#split_urn(urn)
  return s:V.Data.String.nsplit(substitute(a:urn, '^docbase:', '', ''), 3, '/')
endfunction

function! docbase#parse_urn(urn)
  let l:parts = docbase#split_urn(a:urn)
  return {
  \   'type': l:parts[0],
  \   'domain': l:parts[1],
  \   'id': get(l:parts, 2, '')
  \ }
endfunction

function! docbase#build_urn(type, domain, id)
  if a:id ==# ''
    return printf('docbase:%s/%s', a:type, a:domain)
  endif
  return printf('docbase:%s/%s/%d', a:type, a:domain, a:id)
endfunction

function! s:check_domain(domain)
  if a:domain ==# ''
    throw 'invalid operation: it is tried to get docbase client without domain'
  endif
endfunction

function! docbase#client(domain)
  call s:check_domain(a:domain)

  let l:docbase = get(g:, 'docbase', [])
  let l:option = {}

  let l:options = filter(l:docbase, { _, opt -> get(opt, 'domain', '') ==# a:domain })
  if len(l:options) == 0
    throw 'g:docbase has no option for "' . a:domain . '"'
  endif
  let l:option = l:options[0]

  if !has_key(l:option, 'domain')
    throw 'g:docbase has no domain option'
  elseif !has_key(l:option, 'token')
    throw 'g:docbase has no token option'
  endif
  return docbase#api#new(l:option.domain, l:option.token)
endfunction

function! docbase#list_posts(...)
  let l:domain = get(g:, 'docbase_domain', '')
  if len(a:000) == 1
    let l:domain = a:0
  endif
  call s:check_domain(l:domain)

  execute 'split ' . docbase#build_urn('posts', l:domain, '')
endfunction

