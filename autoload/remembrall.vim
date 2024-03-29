" The MIT License (MIT)
"
" Copyright (c) 2018 Urbain Vaes
"
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to deal
" in the Software without restriction, including without limitation the rights
" to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
" copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
"
" The above copyright notice and this permission notice shall be included in
" all copies or substantial portions of the Software.
"
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
" OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
" THE SOFTWARE.

let s:defaultWindow = "topleft 10new"
let s:defaultZoomKey = "\<c-t>"
let s:defaultSearch = 1
let s:defaultAutoAccept = 1
let s:defaultAcceptKey = "\<c-m>"
let s:defaultFloating = has("nvim")

let s:scroll = {
      \ "\<up>":       "\<c-y>", "\<c-y>": "\<c-y>",
      \ "\<down>":     "\<c-e>", "\<c-e>": "\<c-e>",
      \ "\<pageup>":   "\<c-b>", "\<c-b>": "\<c-b>",
      \ "\<pagedown>": "\<c-f>", "\<c-f>": "\<c-f>" }

let s:literal_to_printable = {
      \ "\<Space>" : "<Space>",
      \ "\<C-A>" : "<C-A>", "\<C-B>" : "<C-B>", "\<C-C>" : "<C-C>", "\<C-D>" : "<C-D>",
      \ "\<C-E>" : "<C-E>", "\<C-F>" : "<C-F>", "\<C-G>" : "<C-G>", "\<C-H>" : "<C-H>",
      \ "\<C-I>" : "<C-I>", "\<C-J>" : "<C-J>", "\<C-K>" : "<C-K>", "\<C-L>" : "<C-L>",
      \ "\<C-M>" : "<C-M>", "\<C-N>" : "<C-N>", "\<C-O>" : "<C-O>", "\<C-P>" : "<C-P>",
      \ "\<C-Q>" : "<C-Q>", "\<C-R>" : "<C-R>", "\<C-S>" : "<C-S>", "\<C-T>" : "<C-T>",
      \ "\<C-U>" : "<C-U>", "\<C-V>" : "<C-V>", "\<C-W>" : "<C-W>", "\<C-X>" : "<C-X>",
      \ "\<C-Y>" : "<C-Y>", "\<C-Z>" : "<C-Z>" }

let s:f_keys = {
      \ "\<F1>": "<F1>", "\<F2>" :  "<F2>", "\<F3>" :  "<F3>", "\<F4>" : "<F4>",
      \ "\<F5>": "<F5>", "\<F6>" :  "<F6>", "\<F7>" :  "<F7>", "\<F8>" : "<F8>",
      \ "\<F9>": "<F9>", "\<F10>": "<F10>", "\<F11>": "<F11>", "\<F12>": "<F12>"}

" From vim-peekaboo
function! s:getpos()
  return {'tab': tabpagenr(), 'buf': bufnr(''), 'win': winnr(), 'cnt': winnr('$')}
endfunction

" From vim-peekaboo: Triggers gv to keep visual highlight on
function! s:redraw(mode)
  let visible =  s:positions.current.tab == s:positions.remembrall.tab
        \ && !s:zoom && !s:inplace
  if a:mode == 'v' && visible
    noautocmd wincmd p
    normal! gv
    redraw
    noautocmd wincmd p
  else
    redraw
  endif
endfunction

function! s:l2p(l_string)
  let p_string = ''
  for s:char in split(a:l_string, '\zs')
    let p_string = p_string . get(s:literal_to_printable, s:char, s:char)
  endfor
  return p_string
endfunction

function! s:p2s(p_string)
  let leader = get(g:, 'mapleader', '\\')
  let s_string = substitute(a:p_string, '<Leader>', leader, 'g')
  return escape(s_string, '\/^$.*~[]')
endfunction

function! s:open()
  let s:zoom = 0
  let [s:stl, s:lst, s:winrestcmd] = [&showtabline, &laststatus, winrestcmd()]
  let s:sol = &l:startofline
  let s:alternate = @#
  setlocal nostartofline
  let s:positions = { 'current': s:getpos() }
  let floating = get(g:, 'remembrall_flating', s:defaultFloating)
  if floating
    let s:inplace = 0
    let width = (&columns / 3) * 2
    let [row, column] = [1, &columns / 6]
    let buf = nvim_create_buf(v:false, v:true)
    call nvim_buf_set_lines(buf, 0, 1, v:true, ["> Remembrall"])
    let opts = {
          \ 'relative': 'editor',
          \ 'anchor': 'NW',
          \ 'style': 'minimal',
          \ 'width': width,
          \ 'height': 10,
          \ 'row': 2,
          \ 'col': column,
          \ 'border': 'rounded'
          \ }
    let winid = nvim_open_win(buf, 0, opts)
    let hlgroup = "RemembrallFloating"
    call setwinvar(winid, '&winhl', 'FloatBorder:'.hlgroup.',Normal:'.hlgroup.',NormalNC:'.hlgroup.',FoldColumn:'.hlgroup)
    " call setwinvar(winid, '&winhl', 'FloatBorder:'.hlgroup)
    exe win_id2win(winid)."wincmd w"
    let s:is_floating = 1
  else
    execute get(g:, 'remembrall_window', s:defaultWindow)
    let s:positions.remembrall = s:getpos()
    let s:inplace = s:positions.current.tab == s:positions.remembrall.tab &&
          \ s:positions.current.win == s:positions.remembrall.win &&
          \ s:positions.current.cnt == s:positions.remembrall.cnt
    setlocal statusline=>\ Remembrall nocursorline nofoldenable
    let s:is_floating = 0
  end
  setlocal filetype=remembrall nonumber nospell buftype=nofile bufhidden=hide
        \ nobuflisted nowrap modifiable  statusline=>\ Remembrall nocursorline nofoldenable
  let s:positions.remembrall = s:getpos()
endfunction

function! s:toggleZoom()
  if s:zoom
    tab close
    let [&showtabline, &laststatus] = [s:stl, s:lst]
    noautocmd execute 'tabnext' s:positions.current.tab
  else
    let statusline=&statusline
    tab split
    set showtabline=0
  endif
  let s:zoom = !s:zoom
endfunction

function! remembrall#close(mode, feedargs)
  if s:zoom
    call s:toggleZoom()
  endif
  if s:inplace
    silent noautocmd execute 'buf' s:positions.current.buf
  else
    " Works only if same window
    noautocmd wincmd p
  endif
  silent execute 'bdelete' s:positions.remembrall.buf
  if a:mode == 'v'
    normal! gv
  endif
  let &l:startofline = s:sol
  if s:alternate != '' && s:inplace
    let @# = s:alternate
  endif
  " execute s:winrestcmd
  redraw
  call feedkeys(a:feedargs[0], a:feedargs[1])
endfunction

function! s:search()
  nnoremap <silent> <buffer> <cr> :
        \ let keys=matchstr(getline('.'), "[^ ]*", 4) \|
        \ call remembrall#close('n', [eval('"'.escape(keys, '\<"').'"'), ''])<cr>
  nnoremap <silent> <buffer> q :call remembrall#close('n', ['', ''])<cr>
  nnoremap <silent> <buffer> <esc> :call remembrall#close('n', ['', ''])<cr>
  call feedkeys('/', 'n')
endfunction

function! s:display_matches(mode, p_prefix, s_prefix)
  if a:mode == 'n' | let map_command = 'nmap'
  elseif a:mode == 'v' | let map_command = 'vmap'
  endif

  silent noautocmd execute 'buf' s:positions.current.buf
  redir => mappings | silent execute map_command a:p_prefix | redir END
  silent noautocmd execute 'buf' s:positions.remembrall.buf

  silent %delete _
  silent put=mappings
  silent execute 'vglobal/\m^...' . a:s_prefix . '/d _'
  silent execute 'global/Remembrall/d _'
  silent! %substitute/\m^\(...\)/\1 /
  if s:is_floating
    let [firstLine, secondLine] = ["> Remembrall: ".a:p_prefix, ""]
    silent 0put=firstLine
    silent 1put=secondLine
  end
  call histdel("search", -1)
  let @/ = histget("search", -1)
  syntax clear hintArg
  execute 'syntax match hintArg /\m\s' . a:s_prefix . '/ contained nextgroup=hintMap'
endfunction

function! s:hints(mode, prefix, newch)

  let prefix = a:prefix . a:newch
  let p_prefix = s:l2p(prefix)
  let s_prefix = s:p2s(p_prefix)

  call s:display_matches(a:mode, p_prefix, s_prefix)

  if line('$') == 1 + 2*s:is_floating
    if search('^....'.s_prefix.'\s') || !search('^....'.s_prefix)
      if get(g:, "remembrall_auto_accept", s:defaultAutoAccept)
        return prefix
      endif
    endif
  endif

  exe "setlocal statusline=>\\ Remembrall:\\ ".substitute(prefix, " ", "<Space>", "g")

  call s:redraw(a:mode)
  while 1
    let ch = getchar()
    let char = get(s:f_keys, ch, nr2char(ch))

    let key = get(s:scroll, ch, get(s:scroll, char, ''))
    if !empty(key)
      execute 'normal!' key
      call s:redraw(a:mode)
      continue
    endif

    if char == get(g:, "remembrall_zoom_key", s:defaultZoomKey)
      call s:toggleZoom()
      call s:redraw(a:mode)
      continue
    endif

    if char == "/" && get(g:, "remembrall_search", s:defaultSearch)
      call s:search()
      return "in_search"
    endif

    if ch == "\<bs>" || char == "\<c-h>"
      let prefix = strpart(prefix, 0, strlen(prefix) - 1)
      return s:hints(a:mode, prefix, '')
    endif

    if char == ''
      return ''
    endif

    if char == s:defaultAcceptKey
      return prefix
    endif

    return s:hints(a:mode, prefix, char)
  endwhile
endfunction

function! remembrall#remind(mode, chars)
  let countVar = v:count > 0 ? v:count : ""
  let default_register =
        \ &clipboard =~ '.*\<unnamedplus\>.*' ? '+' :
        \ &clipboard =~ '.*\<unnamed\>.*' ? '*' : '"'
  let register = v:register ==# default_register ? '' : '"'.v:register

  " Legacy, use <expr> instead
  if getchar(1)
    call feedkeys(register.countVar.a:chars, 'ni')
    return
  endif

  call s:open()
  try
    let keys = s:hints(a:mode, a:chars, '')
  catch /^Vim:Interrupt$/
    let keys = ''
  endtry
  if keys != "in_search"
    call remembrall#close(a:mode, [register.countVar.keys, keys == a:chars ? 'n' : ''])
  endif
endfunction

" vim: sw=2
