" vim-docbase will read or write DocBase posts.
"
" This script will be called by vim-metarw (https://github.com/kana/vim-metarw)
" If you want to ref metarw help: `:help metarw-schemes`
"
" Author: kyoh86
" License: MIT

" Function: metarw#docbase#read({fakepath})
" Arg:
"   - fakepath for docbase docbase:[<domain>[:<post-id>]]
function! metarw#docbase#read(fakepath) abort
  let l:urn = docbase#urn#parse(a:fakepath)
  let b:docbase_urn = l:urn
  return l:urn.read()
endfunction

" Function: metarw#docbase#write({fakepath}, {line1}, {line2}, {append_p})
" Arg:
"   - fakepath for docbase docbase:[<domain>[:<post-id>]]
"   - line1 will be ignored
"   - line2 will be ignored
"   - append_p will be ignored
function! metarw#docbase#write(fakepath, line1, line2, append_p) abort
  try
    call docbase#urn#parse(a:fakepath).write()
    return ['done', '']
  catch
    return ['error', v:exception]
  endtry
endfunction

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
  echom 'arg:'.a:arg_lead
  echom 'cmd:'.a:cmdline
  let l:list = l:urn.complete(a:arg_lead, a:cmdline, a:cursor_pos)
  echom json_encode(l:list)
  return l:list
endfunction
