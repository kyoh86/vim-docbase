let s:V = vital#docbase#new()
call s:V.load('Web.HTTP')
call s:V.load('Web.JSON')

let s:baseUrl = 'https://api.docbase.io'

let s:api = {}
let s:posts = {}

function! s:api.posts()
  let service = deepcopy(s:posts)
  let service.root = self
  return service
endfunction

" Function: list posts
" Arguments:
"   - params: dict having below keys
"     - query: query to search posts
"     - page: page index
"     - per_page: number of posts in each pages
function! s:posts.list(params)
  return self.root.get('/posts', a:params).posts
endfunction

" Function: get a post
" Arguments:
"   - post_id: id of a post
function! s:posts.get(post_id)
  return self.root.get('/posts/' . a:post_id, {})
endfunction

function! s:api.header()
  return {'Content-type': 'application/json', 'X-DocBaseToken': self.token}
endfunction

function! s:api.teamUrl(path)
  return s:baseUrl . '/teams/' . self.domain . a:path
endfunction

function! s:api.get(path, param)
  let l:response = s:V.Web.HTTP.get(self.teamUrl(a:path), a:param, self.header())
  if l:response.status != 200
    throw printf('failed to docbase.get')
  endif
  return s:V.Web.JSON.decode(l:response.content)
endfunction

function! docbase#api#new(domain, token)
  let client = deepcopy(s:api)
  let client.domain = a:domain
  let client.token = a:token
  return client
endfunction

