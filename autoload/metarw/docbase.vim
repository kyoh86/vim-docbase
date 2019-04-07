function! metarw#docbase#read(fakepath)
  echom 'read: ' . a:fakepath
  let l:target = docbase#parse_urn(a:fakepath)
  let l:api = docbase#client(l:target.domain)
  let l:post = l:api.posts().get(l:target.post_id)
  " frontmatters:
  "   パラメータ	内容	型	必須	デフォルト値
  "   title	メモのタイトル	String		
  "   body	メモの本文	String		
  "   draft	下書き保存にするかどうか	Boolean		
  "   notice	通知するかどうか	Boolean		true
  "   tags	タグ名の配列	String Array		
  "   scope	公開範囲	String	groupsを指定するときのみscopeはgroupが必須	
  "   groups	グループID配列	Integer Array	scopeがgroupの時のみ必須

  let l:tags = map(get(l:post, 'tags', []), { _, t -> t.name })
  let l:groups = map(get(l:post, 'groups', []), { _, g -> g.name })
  let l:content = [
    \ '---',
    \ 'title: ' . l:post.title,
    \ 'draft: ' . get(l:post, 'draft', 'false'),
    \ 'notice: true',
    \ 'tags: ' . s:yaml_list(l:tags),
    \ 'scope: ' . l:post.scope
    \ ]
  if l:post.scope ==# 'group'
    let l:content += [
      \ 'groups: ' . s:yaml_list(l:groups)
    \ ]
  endif
  let l:content += [
    \ '---',
    \ substitute(l:post.body, "\r", "", "g")
  \ ]

  return ['read', { -> join(l:content, "\n")}]
endfunction

function! s:yaml_list(list)
  return len(a:list) > 0 ? "\n  - " . join(a:list, "\n  - ") : '[]'
endfunction

function! metarw#docbase#write(fakepath, line1, line2, append_p)
endfunction

function! metarw#docbase#complete(argLead, cmdLine, cursorPos)
endfunction
