function! s:detect_docbase() abort
  if has_key(b:, 'docbase_urn')
    if b:docbase_urn.domain ==# '' || b:docbase_urn.id ==# ''
      set filetype=docbase-browse
    endif
    set filetype=docbase
  endif
endfunction

autocmd BufEnter,BufRead,BufNewFile docbase:* :call <SID>detect_docbase()
