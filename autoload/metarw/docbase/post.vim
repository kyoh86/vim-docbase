scriptencoding utf-8

let s:V = vital#docbase#new()
call s:V.load('Data.String')

function! metarw#docbase#post#list_id(domain) abort
  echo 'メモを読み込んでいます...'
  let l:api = docbase#api#for(a:domain)
  return l:api.post().list_id({'per_page': 100})
endfunction

function! metarw#docbase#post#list_urn(domain) abort
  echo 'メモを読み込んでいます...'
  let l:api = docbase#api#for(a:domain)
  return l:api.post().list_urn({'per_page': 100})
endfunction

function! metarw#docbase#post#list(domain) abort
  echo 'メモを読み込んでいます...'
  let l:api = docbase#api#for(a:domain)
  let l:posts = l:api.post().list({'per_page': 100})
  let l:posts = map(l:posts, {_, item -> {
        \ 'fakepath': 'docbase:' . a:domain . ':' . item.id,
        \ 'label': item.title
        \ }})
  let l:posts =
        \ [{
        \   'fakepath': 'docbase:',
        \   'label': 'List Domains'
        \ },{
        \   'fakepath': 'docbase:' . a:domain . ':new',
        \   'label': 'メモの新規作成'
        \ }] + l:posts
  return l:posts
endfunction

function! metarw#docbase#post#read(urn) abort
  echom 'メモを読み込んでいます...'
  let l:api = docbase#api#for(a:urn.domain)
  let l:post = l:api.post().get(a:urn.id)

  " frontmatters:
  let l:tags = map(get(l:post, 'tags', []), { _, t -> t.name })
  let l:groups = map(get(l:post, 'groups', []), { _, g -> g.name })
  let l:scope = get(l:post, 'scope', v:null)
  let l:content = [
    \ '---',
    \ 'title: ' . json_encode(l:post.title),
    \ 'draft: ' . json_encode(get(l:post, 'draft', v:false)),
    \ 'notice: true',
    \ 'scope: ' . json_encode(l:scope),
    \ ]
  let l:content += s:yaml_list('tags', l:tags)
  if l:scope ==# 'group'
    let l:content += s:yaml_list('groups', l:groups)
  endif
  let l:content += [ '---' ]

  " start position
  let b:docbase_start_lnum = len(l:content) + 1

  " add content
  let l:content += [
    \ substitute(l:post.body, "\r", '', 'g')
    \ ]

  redraw
  return join(l:content, "\n")
endfunction

function! metarw#docbase#post#new(urn) abort
  " frontmatters:
  let l:content = [
    \ '---',
    \ 'title: ',
    \ 'draft: true',
    \ 'notice: true',
    \ 'tags: []',
    \ 'scope: private',
    \ '---',
    \ ''
  \ ]
  let b:docbase_start_lnum = 2
  let b:docbase_start_col = strlen('title: ')

  redraw
  return join(l:content, "\n")
endfunction

function! s:yaml_list(prop, list)
  if len(a:list) > 0
    return [a:prop . ':'] + map(a:list, {_, i -> '  - ' . i})
  endif
  return [a:prop . ': []']
endfunction

function! s:parse_post() abort
  let l:tags = []
  let l:groups = []

  let l:frontmatter = 0
  let l:in_tags = v:false
  let l:in_groups = v:false

  " Frontmatterを解析してドキュメント情報を取得する
  let l:post = {}
  let l:list_pattern = '^   *- *'
	for l:l in range(1, line('$'))
    let l:line = getline(l:l)
    if l:line ==# ''
      continue
    endif

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
      let [l:key; l:values] = split(l:line, ':', v:true)
      if len(l:values) < 1
        throw printf('invalid frontmatter "%s" at line %d', l:line, l:l)
      endif
      let l:key = s:V.Data.String.trim_end(l:key)
      let l:value = s:V.Data.String.trim_start(join(l:values, ':'))

      try
        let l:value = json_decode(l:value)
      catch
      endtry

      if l:key ==# 'tags'
        if type(l:value) == v:t_list
          let l:tags = l:value
        else
          let l:in_tags = v:true
        endif
      elseif l:key ==# 'groups'
        if type(l:value) == v:t_list
          let l:groups = l:value
        else
          let l:in_groups = v:true
        endif
      else
        let l:post[l:key] = l:value
      endif
    endif
  endfor
  if get(l:post, 'scope', '') ==# 'group'
    let l:post['groups'] = l:groups
  endif
  if get(l:post, 'scope', v:null) == v:null
    " DocBase APIが、draft = trueのときにscope = nullで返してくるが、
    " patchにはscope = nullを許容しないため、回避するために 'private'
    " を設定する
    let l:post['scope'] = 'private'
  endif
  let l:post['tags'] = l:tags

  " Frontmatterを除いた本文を取得して改行でつなぐ
  let l:post['body'] = join(getline(l:frontmatter, '$'), "\n")

  return l:post
endfunction

function! metarw#docbase#post#write(urn) abort
  let l:post = s:parse_post()
  let l:api = docbase#api#for(a:urn.domain)
  call l:api.post().update(a:urn.id, l:post)
  return ''
endfunction

function! metarw#docbase#post#create(urn) abort
  let l:post = s:parse_post()
  let l:api = docbase#api#for(a:urn.domain)
  let l:post = l:api.post().create(l:post)

  " IDを投稿した結果のIDに置き換える
  let a:urn.id = l:post.id
  execute 'file ' . a:urn.string()
  return ''
endfunction

