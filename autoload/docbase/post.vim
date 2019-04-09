let s:V = vital#docbase#new()
call s:V.load('Data.String')

function! docbase#post#list() abort
  echo 'Loading posts...'
  let l:page = b:docbase_path.page(1)
  let l:posts = b:docbase_path.client().post().list({'page': l:page, 'per_page': 100})

  redraw
  return docbase#menu#create(l:posts, v:true)
endfunction

function! docbase#post#read() abort
  echo 'Loading a post...'
  let l:post = b:docbase_path.client().post().get(b:docbase_path.id)

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
  redraw
  return join(l:content, "\n")
endfunction

function! s:yaml_list(list)
  return len(a:list) > 0 ? "\n  - " . join(a:list, "\n  - ") : '[]'
endfunction

function! docbase#post#write() abort
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
  call b:docbase_path.client().post().update(b:docbase_path.id, l:option)
  return ''
endfunction

