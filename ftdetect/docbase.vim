function! s:detect_docbase() abort
  if has_key(b:, 'docbase_urn') 
    execute 'set filetype=' . b:docbase_urn.filetype() 
  endif
endfunction

autocmd BufEnter docbase:* :call <SID>detect_docbase()
