function! docbase#posts#list(domain)
  let l:api = docbase#client(a:domain)
  let l:posts = l:api.posts().list({})
  let l:lines = map(l:posts, { _, post -> printf('%d: %s', post.id, post.title) })
  let l:helps = [
        \ '; ------------------------------------------',
        \ '; Press <Enter> to edit a post in the line.',
        \ '; To split window, press <C-v> or <C-x>.',
        \ '; To fetch next page, press <C-n>.',
        \ '; To quit, press "q".',
        \ '; ------------------------------------------',
      \ ]
  let b:docbase_domain = a:domain
  let b:docbase_startpos = len(l:helps) + 1
  setlocal ft=docbase-list buftype=nofile bufhidden=hide
  syntax match Number /^[0-9]\+\ze:/
  syntax match Visual /^.*\%#.*/
  syntax match Comment /^;.*/

  autocmd BufEnter <buffer> silent call cursor(b:docbase_startpos, 1) | silent setlocal nomodified nomodifiable readonly

  nnoremap <nowait> <silent> <buffer> <esc> :bw!<cr>
  nnoremap <nowait> <silent> <buffer> q :bw!<cr>
  nnoremap <nowait> <silent> <buffer> <cr> :call <SID>list_posts_action('edit')<cr>
  nnoremap <nowait> <silent> <buffer> <C-v> :call <SID>list_posts_action('vertical new')<cr>
  nnoremap <nowait> <silent> <buffer> <C-x> :call <SID>list_posts_action('new')<cr>
  nnoremap <nowait> <silent> <buffer> <C-n> :call <SID>list_posts_next()<cr>

  return l:helps + l:lines
endfunction

function! docbase#posts#read(domain, post_id)
  let l:api = docbase#client(a:domain)
  let l:post = l:api.posts().get(a:post_id)

  " frontmatters:
  let l:tags = map(get(l:post, 'tags', []), { _, t -> t.name })
  let l:groups = map(get(l:post, 'groups', []), { _, g -> g.name })
  let l:scope = get(l:post, 'scope', v:null)
  let l:content = [
    \ '---',
    \ 'title: ' . json_encode(l:post.title),
    \ 'draft: ' . json_encode(get(l:post, 'draft', v:false)),
    \ 'notice: true',
    \ 'tags: ' . s:yaml_list(l:tags),
    \ 'scope: ' . json_encode(l:scope)
    \ ]
  if l:scope ==# 'group'
    let l:content += [
      \ 'groups: ' . s:yaml_list(l:groups)
    \ ]
  endif
  let l:content += [
    \ '---',
    \ substitute(l:post.body, "\r", "", "g")
  \ ]

  setl ft=docbase syntax=markdown
  return join(l:content, "\n")
endfunction

function! s:yaml_list(list)
  return len(a:list) > 0 ? "\n  - " . join(a:list, "\n  - ") : '[]'
endfunction

function! s:list_posts_action(edit)
  let l:line = getline('.')
  if l:line =~# '^; '
    return
  endif
  let l:post_id = split(l:line, ':')[0]
  echom docbase#build_urn('posts', b:docbase_domain, l:post_id)
  execute a:edit . ' ' . docbase#build_urn('posts', b:docbase_domain, l:post_id)
endfunction

"TODO: list_posts_next

function! docbase#posts#write(domain, id) abort
  let l:api = docbase#client(a:domain)

  let l:tags = []
  let l:groups = []

  let l:frontmatter = 0
  let l:in_tags = v:false
  let l:in_groups = v:false

  " Frontmatterを解析してドキュメント情報を取得する
  let l:option = {}
  let l:list_pattern = '^   *- *'
	for l:l in range(1, line('$'))
    let l:line = getline(l:l)
    if l:frontmatter == 0
      if l:line ==# '---'
        let l:frontmatter = 1
      endif
    elseif l:frontmatter == 1
      if l:line ==# '---'
        let l:frontmatter = l:l + 1
        break
      endif
      if l:in_tags
        if match(l:line, l:list_pattern) != -1
          let l:tags += [trim(substitute(l:line, l:list_pattern, '', ''))]
          continue
        else
          let l:in_tags = v:false
        endif
      endif
      if l:in_groups
        if match(l:line, l:list_pattern) != -1
          let l:groups += [trim(substitute(l:line, l:list_pattern, '', ''))]
          continue
        else
          let l:in_groups = v:false
        endif
      endif
      let l:parts = s:V.Data.String.nsplit(l:line, 2, ':')
      if len(l:parts) < 2
        throw printf('invalid frontmatter "%s" at line %d', l:line, l:l)
      endif
      let l:key = s:V.Data.String.trim_end(l:parts[0])
      let l:value = json_decode(s:V.Data.String.trim_start(l:parts[1]))
      if l:key ==# 'tags'
        " TODO: support ['foo', 'bar'] notation
        let l:in_tags = v:true
      elseif l:key ==# 'groups'
        " TODO: support ['foo', 'bar'] notation
        let l:in_groups = v:true
      else
        let l:option[l:key] = l:value
      endif
    endif
  endfor
  if get(l:option, 'scope', '') ==# 'group'
    let l:option['groups'] = l:groups
  endif
  if get(l:option, 'scope', v:null) == v:null
    " DocBase APIが、draft = trueのときにscope = nullで返してくるが、
    " patchにはscope = nullを許容しないため、回避するために 'private'
    " を設定する
    let l:option['scope'] = 'private'
  endif
  let l:option['tags'] = l:tags

  " Frontmatterを除いた本文を取得して改行でつなぐ
  let l:option['body'] = join(getline(l:frontmatter, '$'), "\n")
  call l:api.posts().update(a:id, l:option)
  return ['done', '']
endfunction

