function! metarw#docbase#read(fakepath) abort
  let l:path = docbase#path#parse(a:fakepath)
  let b:docbase_path = l:path
  return ['read', l:path.reader()]
endfunction

function! metarw#docbase#write(fakepath, line1, line2, append_p) abort
  let l:path = docbase#path#parse(a:fakepath)
  let b:docbase_path = l:path
  let l:Writer = l:path.writer()
  try
    call l:Writer()
    return ['done', '']
  catch
    return ['error', v:exception]
  endtry
endfunction
