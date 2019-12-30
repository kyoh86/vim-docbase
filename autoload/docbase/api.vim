let s:V = vital#docbase#new()
call s:V.load('Web.HTTP')

let s:api_cache = {}

function! docbase#api#for(domain) abort
  if has_key(s:api_cache, a:domain)
    return s:api_cache[a:domain]
  endif

  let l:option = docbase#config#for(a:domain)

  let l:api = docbase#api#new(a:domain, l:option.token)
  let s:api_cache[a:domain] = l:api
  return l:api
endfunction

let s:base_url = 'https://api.docbase.io'

let s:api = {}
let s:post = {}

function! s:api.post()
  let service = deepcopy(s:post)
  let service.root = self
  return service
endfunction

function! s:post.list(params)
  return self.root.get_in_team('/posts', a:params).posts
endfunction

function! s:post.list_id(params) abort
  return map(self.list(a:params), {_, item -> item.id})
endfunction

function! s:post.get(post_id)
  return self.root.get_in_team('/posts/' . a:post_id, {})
endfunction

function! s:post.update(post_id, content)
  return self.root.patch_in_team('/posts/' . a:post_id, a:content)
endfunction

function! s:post.create(content)
  return self.root.post_in_team('/posts', a:content)
endfunction

function! s:api.header()
  return {'Content-type': 'application/json', 'X-DocBaseToken': self.token, 'X-Api-Version': '2'}
endfunction

function! s:api.team_url(path)
  return s:base_url . '/teams/' . self.domain . a:path
endfunction

function! s:api.get_in_team(path, param)
  let l:response = s:V.Web.HTTP.get(self.team_url(a:path), a:param, self.header())
  if l:response.status >= 400
    throw printf('failed to docbase.get (%d: %s)', l:response.status, l:response.content)
  endif
  return json_decode(l:response.content)
endfunction

function! s:api.patch_in_team(path, body)
  let l:response = s:V.Web.HTTP.request(
    \ 'PATCH',
    \ self.team_url(a:path),
    \ {
      \ 'data': json_encode(a:body),
      \ 'headers': self.header()
    \ }
  \ )
  if l:response.status >= 400
    throw printf('failed to docbase.patch (%d: %s)', l:response.status, l:response.content)
  endif
  return json_decode(l:response.content)
endfunction

function! s:api.post_in_team(path, body)
  let l:response = s:V.Web.HTTP.request(
    \ 'POST',
    \ self.team_url(a:path),
    \ {
      \ 'data': json_encode(a:body),
      \ 'headers': self.header()
    \ }
  \ )
  if l:response.status >= 400
    throw printf('failed to docbase.post (%d: %s)', l:response.status, l:response.content)
  endif
  return json_decode(l:response.content)
endfunction

function! docbase#api#new(domain, token)
  let api = deepcopy(s:api)
  let api.domain = a:domain
  let api.token = a:token
  return api
endfunction

