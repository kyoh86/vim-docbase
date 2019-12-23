function! docbase#menu#create(menus, paging) abort
  let l:lines = map(copy(a:menus), { _, menu -> join(menu, ': ')})
  let l:helps = [
        \ '; ' . toupper(b:docbase_urn.string()),
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
  let b:docbase_start_lnum = len(l:helps) + 1
  let b:docbase_paging = a:paging

  return l:helps + l:lines
endfunction

function! docbase#menu#action(edit)
  let l:line = getline('.')
  if l:line =~# '^; '
    return
  endif
  let l:next_path = b:docbase_urn.digg(split(l:line, ':')[0])
  let l:bufnr = bufnr('%')
  execute a:edit . ' ' . l:next_path.string()
  execute 'bw!' . l:bufnr
endfunction

function! docbase#menu#next()
  let l:next_path = b:docbase_urn.next_page()
  let l:bufnr = bufnr('%')
  execute 'edit ' . l:next_path.string()
  execute 'bw!' . l:bufnr
endfunction

function! docbase#menu#prev()
  let l:prev_path = b:docbase_urn.prev_page()
  let l:bufnr = bufnr('%')
  execute 'edit ' . l:prev_path.string()
  execute 'bw!' . l:bufnr
endfunction
