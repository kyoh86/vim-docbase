function! metarw#docbase#read(fakepath) abort
  let l:path = docbase#urn#parse(a:fakepath)
  let b:docbase_urn = l:path
  "TODO: use metarw#{scheme}#read()-browse
  return ['read', l:path.reader()]
endfunction

function! metarw#docbase#write(fakepath, line1, line2, append_p) abort
  let l:path = docbase#urn#parse(a:fakepath)
  let b:docbase_urn = l:path
  let l:Writer = l:path.writer()
  try
    call l:Writer()
    return ['done', '']
  catch
    return ['error', v:exception]
  endtry
endfunction
function! metarw#complete({arglead}, {cmdline}, {cursorpos})
