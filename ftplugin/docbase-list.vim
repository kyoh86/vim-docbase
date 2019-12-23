silent setlocal buftype=nofile bufhidden=hide

silent call cursor(get(b:, 'docbase_start_lnum', 1), get(b:, 'docbase_start_col', 1))
silent setlocal nomodified nomodifiable readonly

silent nnoremap <nowait> <silent> <buffer> <esc> :bw!<cr>
silent nnoremap <nowait> <silent> <buffer> gq    :bw!<cr>
silent nnoremap <nowait> <silent> <buffer> <cr>  :call docbase#menu#action('edit')<cr>
silent nnoremap <nowait> <silent> <buffer> <C-v> :call docbase#menu#action('vnew')<cr>
silent nnoremap <nowait> <silent> <buffer> <C-x> :call docbase#menu#action('new')<cr>

if get(b:, 'docbase_paging')
  silent nnoremap <nowait> <silent> <buffer> <C-n> :call docbase#menu#next()<cr>
  silent nnoremap <nowait> <silent> <buffer> <C-p> :call docbase#menu#prev()<cr>
endif
