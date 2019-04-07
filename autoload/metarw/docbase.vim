let s:V = vital#docbase#new()
call s:V.load('Data.String')

function! metarw#docbase#read(fakepath) abort
  let l:target = docbase#split_urn(a:fakepath)
  let l:verb = ['list', 'read'][len(l:target) - 2]
  let l:funcname = printf('docbase#%s#%s', l:target[0], l:verb)
  return ['read', function(l:funcname, l:target[1:])]
endfunction

function! metarw#docbase#write(fakepath, line1, line2, append_p) abort
  let l:target = docbase#parse_urn(a:fakepath)
  let l:funcname = printf('docbase#%s#write', l:target[0])
  return ['read', function(l:funcname, [l:target.domain, l:target.id])]
endfunction
