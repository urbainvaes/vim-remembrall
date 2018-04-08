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

let s:default_window = 'topleft 10new'
let [s:defaultZoomKey, s:defaultAcceptKey] = ["\<c-t>", "\<c-m>"]

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
  execute get(g:, 'remembrall_window', s:default_window)
  let s:positions.remembrall = s:getpos()
  let s:inplace = s:positions.current.tab == s:positions.remembrall.tab &&
        \ s:positions.current.win == s:positions.remembrall.win &&
        \ s:positions.current.cnt == s:positions.remembrall.cnt
  let s:hlsearch = &hlsearch
  let s:vhlsearch = v:hlsearch
  set nohlsearch
  setlocal filetype=remembrall nonumber nospell buftype=nofile bufhidden=hide
        \ nobuflisted nowrap modifiable  statusline=>\ Remembrall nocursorline nofoldenable
endfunction

function! s:toggleZoom()
  if s:zoom
    tab close
    let [&showtabline, &laststatus] = [s:stl, s:lst]
  else
    tab split
    set showtabline=0 laststatus=0
  endif
  let s:zoom = !s:zoom
endfunction

function! s:close(mode)
  if s:zoom
    call s:toggleZoom()
  endif
  if s:inplace
    silent noautocmd execute 'buf' s:positions.current.buf
  else
    noautocmd wincmd p
  endif
  silent execute 'bdelete' s:positions.remembrall.buf
  if a:mode == 'v'
    normal! gv
  endif
  let &l:startofline = s:sol
  let &hlsearch = s:hlsearch
  let v:hlsearch = s:vhlsearch
  if s:alternate != '' && s:inplace
    let @# = s:alternate
  endif
  " execute s:winrestcmd
endfunction

function! s:display_matches(mode, p_prefix, s_prefix)
  if a:mode == 'n' | let map_command = 'nmap'
  elseif a:mode == 'v' | let map_command = 'vmap'
  endif

  silent noautocmd execute 'buf' s:positions.current.buf
  redir => mappings | silent execute map_command a:p_prefix | redir END
  silent noautocmd execute 'buf' s:positions.remembrall.buf

  %delete _
  silent put=mappings
  silent execute 'vglobal/\m^...' . a:s_prefix . '/d _'
  silent! %substitute/\m^\(...\)/\1 /
  silent norm gg

  syntax clear hintArg
  execute 'syntax match hintArg /\m\s' . a:s_prefix . '/ contained nextgroup=hintMap'
endfunction

function! s:hints(mode, prefix, newch)
  if a:newch == ''
    return ''
  endif
  if a:newch == s:defaultAcceptKey
    return a:prefix
  endif

  let prefix = a:prefix . a:newch
  let p_prefix = s:l2p(prefix)
  let s_prefix = s:p2s(p_prefix)

  call s:display_matches(a:mode, p_prefix, s_prefix)

  if line('$') == 1
    if search('^....'.s_prefix.'\s') || !search('^....'.s_prefix)
      return prefix
    endif
  endif

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

    return s:hints(a:mode, prefix, char)
  endwhile
endfunction

function! remembrall#remind(mode, chars)
  if getchar(1)
    if a:chars =~ 'y\|c\|d'
      if v:count > 0 
        call feedkeys('"'.v:register.v:count.a:chars, 'ni')
      else |
        call feedkeys('"'.v:register.a:chars, 'ni')
      endif
    elseif a:chars =~ '>\|<\|='
      if v:count > 0
        call feedkeys(v:count.a:chars, 'ni')
      else
        call feedkeys(a:chars, 'ni')
      endif
    else
      call feedkeys(a:chars, 'ni')
    endif
    return
  endif
  call s:open()
  try
    let keys = s:hints(a:mode, a:chars, '')
  catch /^Vim:Interrupt$/
    let keys = ''
  endtry
  call s:close(a:mode)
  redraw
  call feedkeys(keys)
endfunction

" vim: sw=2
