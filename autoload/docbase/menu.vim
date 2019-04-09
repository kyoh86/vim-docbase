function! docbase#menu#create(menus, paging) abort
  let l:page = b:docbase_path.page()
  let l:lines = map(copy(a:menus), { _, menu -> printf('%s: %s', menu.id, menu.title) })
  let l:helps = [
        \ '; ' . toupper(b:docbase_path.string()),
        \ ';',
        \ '; * Press <Enter> to enter in the line.',
        \ '; * To split window, press <C-v> or <C-x>.'
      \ ]
  if a:paging
    let l:helps += ['; * To fetch next/previous page, press <C-n>/<C-p>.']
  endif
  let l:helps += [
        \ '; * To quit, press "q".',
        \ '; -------------------------------------------------'
      \ ]
  let b:docbase_startpos = len(l:helps) + 1
  setlocal ft=docbase-list buftype=nofile bufhidden=hide
  syntax match Number /^[^:]\+\ze:/
  syntax match Visual /^.*\%#.*/
  syntax match Comment /^;.*/

  autocmd BufEnter <buffer> silent call cursor(b:docbase_startpos, 1) | silent setlocal nomodified nomodifiable readonly

  nnoremap <nowait> <silent> <buffer> <esc> :bw!<cr>
  nnoremap <nowait> <silent> <buffer> q     :bw!<cr>
  nnoremap <nowait> <silent> <buffer> <cr>  :call <SID>list_action('edit')<cr>
  nnoremap <nowait> <silent> <buffer> <C-v> :call <SID>list_action('vnew')<cr>
  nnoremap <nowait> <silent> <buffer> <C-x> :call <SID>list_action('new')<cr>

  if a:paging
    nnoremap <nowait> <silent> <buffer> <C-n> :call <SID>list_next()<cr>
    nnoremap <nowait> <silent> <buffer> <C-p> :call <SID>list_prev()<cr>
  endif


  return l:helps + l:lines
endfunction

function! s:list_action(edit)
  let l:line = getline('.')
  if l:line =~# '^; '
    return
  endif
  let l:next_path = b:docbase_path.digg(split(l:line, ':')[0])
  let l:bufnr = bufnr('%')
  execute a:edit . ' ' . l:next_path.string()
  execute 'bw!' . l:bufnr
endfunction

function! s:list_next()
  let l:next_path = b:docbase_path.next_page()
  let l:bufnr = bufnr('%')
  execute 'edit ' . l:next_path.string()
  execute 'bw!' . l:bufnr
endfunction

function! s:list_prev()
  let l:prev_path = b:docbase_path.prev_page()
  let l:bufnr = bufnr('%')
  execute 'edit ' . l:prev_path.string()
  execute 'bw!' . l:bufnr
endfunction
