"TODO: move to docbase#metarw.vim

function! docbase#root#domains(urn)
  let l:domains = docbase#config#domain_names()
  call map(l:domains, { _, domain -> { 'label': domain, 'fakepath': 'docbase:' . domain } })

  return l:domains
endfunction
