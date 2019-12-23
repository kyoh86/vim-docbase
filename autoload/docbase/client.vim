let s:client_cache = {}

function! docbase#client#for(domain) abort
  if has_key(s:client_cache, a:domain)
    return s:client_cache[a:domain]
  endif

  let l:option = docbase#config#for(a:domain)

  let l:client = docbase#api#new(a:domain, l:option.token)
  let s:client_cache[a:domain] = l:client
  return l:client
endfunction

