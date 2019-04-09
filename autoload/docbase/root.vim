function! docbase#root#domains()
  let l:domains = copy(get(g:, 'docbase', []))
  call filter(l:domains, { _, opt -> get(opt, 'domain', '') !=# '' })
  call map(l:domains, { _, opt -> { 'id': opt.domain, 'title': '' }})

  return docbase#menu#create(l:domains, v:false)
endfunction

function! docbase#root#objects()
  let l:objects = [{'id': 'post', 'title': '投稿'}]  " supported objects

  return docbase#menu#create(l:objects, v:false)
endfunction
