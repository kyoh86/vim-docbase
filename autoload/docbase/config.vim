scriptencoding utf-8

function! docbase#config#all()
  return get(g:, 'docbase', {})
endfunction

function! docbase#config#domains()
  let l:docbase = docbase#config#all()
  return get(l:docbase, 'domains', [])
endfunction

function! docbase#config#domain_names()
  return map(copy(docbase#config#domains()), {_, d -> d.domain})
endfunction

function! docbase#config#for(domain) abort
  let l:domains = docbase#config#domains()

  let l:index = 0
  while l:index < len(l:domains)
    let l:opt = l:domains[l:index]
    let l:domain = get(l:opt, 'domain', '')
    if l:domain == ''
      throw 'g:docbase.domains has invalid configuration (empty domain) at '. l:index
    endif
    if l:domain ==# a:domain
      if get(l:opt, 'token', '') == ''
        throw 'g:docbase.domains has invalid configuration (empty token) at '. l:index
      endif
      return l:opt
    endif
    let l:index += 1
  endwhile

  throw 'g:docbase has no option for "' . a:domain . '"'
endfunction
