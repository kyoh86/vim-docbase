function! docbase#root#domains()
  let l:domains = docbase#config#domain_names()
  call map(l:domains, { _, domain -> [ domain ]})

  return docbase#menu#create(l:domains, v:false)
endfunction
