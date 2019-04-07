function! s:list_posts(api)
  let l:bufname = 'docbase-list-' . a:api.domain

  let view = winsaveview()
  silent call winrestview(view)
  let l:winnum = bufwinnr(bufnr(l:bufname))
  if l:winnum != -1
    if l:winnum != bufwinnr('%')
      execute l:winnum 'wincmd w'
    endif
  else
    execute 'silent noautocmd split ' . l:bufname
  endif

  setlocal modifiable
  try
    let l:old_undolevels = &undolevels
    silent %d _
    redraw | echon 'Listing posts... '
    let l:posts = a:api.posts().list({})
    let l:lines = map(l:posts, { _, post -> printf('%d: %s', post.id, post.title) })
    let l:helps = [
          \ '; ------------------------------------------',
          \ '; Press <Enter> to edit a post in the line.',
          \ '; To split window, press <C-v> or <C-x>.',
          \ '; To fetch next page, prexx <C-n>.',
          \ '; To quit, press "q".',
          \ '; ------------------------------------------'
        \ ]
    call setline(1, l:helps + l:lines)
  catch
    bw!
    redraw
    echohl ErrorMsg | echomsg 'list_posts: ' . v:exception | echohl None
    return
  finally
    let &undolevels = l:old_undolevels
  endtry

  call cursor(len(l:helps) + 1, 1)
  setlocal ft=docbase-list buftype=nofile bufhidden=hide noswapfile nomodified nomodifiable readonly
  syntax match Number /^[0-9]\+\ze:/
  syntax match Visual /^.*\%#.*/
  syntax match Comment /^;.*/

  let b:docbase_domain = a:api.domain
  let b:docbase_token = a:api.token
  nnoremap <nowait> <silent> <buffer> <esc> :bw!<cr>
  nnoremap <nowait> <silent> <buffer> q :bw!<cr>
  nnoremap <nowait> <silent> <buffer> <cr> :call <SID>list_action('edit')<cr>
  nnoremap <nowait> <silent> <buffer> <C-v> :call <SID>list_action('vertical new')<cr>
  nnoremap <nowait> <silent> <buffer> <C-x> :call <SID>list_action('new')<cr>
  nnoremap <nowait> <silent> <buffer> <C-n> :call <SID>list_next()<cr>

  nohlsearch
  redraw | echo ''
endfunction

function s:list_action(edit)
  let l:api = docbase#api#new(b:docbase_domain, b:docbase_token)
  let l:line = getline('.')
  if l:line =~# '^; '
    return
  endif
  let l:post_id = split(l:line, ':')[0]
  execute a:edit . ' ' . docbase#build_urn(b:docbase_domain, l:post_id)
endfunction

function! docbase#parse_urn(urn)
  let l:parts = split(substitute(substitute(a:urn, '^docbase:', '', ''), '.md$', '', ''), '/')
  return {
  \   'domain': l:parts[0],
  \   'post_id': l:parts[1]
  \ }
endfunction

function! docbase#build_urn(domain, post_id)
  return printf('docbase:%s/%d.md', a:domain, a:post_id)
endfunction

function! docbase#client(domain)
  let l:docbase = get(g:, 'docbase', 0)
  let l:option = {}
  if type(l:docbase) == v:t_dict
    let l:option = l:docbase
  elseif type(l:docbase) == v:t_list
    if len(l:docbase) == 0
      throw 'g:docbase has no item'
    endif

    let l:options = filter(l:docbase, { _, opt -> get(opt, 'domain', '') ==# a:domain })
    if len(l:options) == 0
      throw 'g:docbase has no option for "' . a:domain . '"'
    endif
    let l:option = l:options[0]
  else
    throw 'g:docbase is not set. Please set "domain" and "token" in it'
  endif

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
  let l:api = docbase#client(l:domain)
  call s:list_posts(l:api)
endfunction

