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

if exists('g:loaded_remembrall') || &compatible
    finish
endif
let g:loaded_remembrall = 1


let s:default_suffixes = [""]
let s:default_normal_keys = ["<Leader>", "<LocalLeader>", "y", "c", "d", "g", "]", "[", ">", "<", "="]

function! Remembrall(...)
  let mode = a:0 == 1 ? 'n' : a:1
  let chars = a:0 == 2 ? a:2 : a:1
  return getchar(1) ? chars :
        \ ":\<c-u>call remembrall#remind(\"" . mode . "\", \"" . chars . "\")\<cr>"
endfunction

function! Remembrall_on()
  vnoremap <silent> <expr> <Leader> Remembrall('v', '')
  let s:normal_keys = get(g:, 'remembrall_normal_keys', s:default_normal_keys)
  let s:suffixes = get(g:, 'remembrall_suffixes', s:default_suffixes)
  if has("patch-7.4.601")
    for suffix in s:suffixes
      for key in s:normal_keys
        silent execute "nnoremap <silent> <expr>" key.suffix "Remembrall('".key."')"
      endfor
    endfor
  endif
  let s:remembrall_on = 1
  echom "Remembrall status: on"
endfunction

function! Remembrall_off()
  vunmap <Leader>
  for suffix in s:suffixes
    for key in s:normal_keys
      silent execute "nunmap" key
    endfor
  endfor
  let s:remembrall_on = 0
  echom "Remembrall status: off"
endfunction

function! Remembrall_toggle()
  call function(s:remembrall_on ? "Remembrall_off" : "Remembrall_on")()
endfunction

command! -nargs=0 RemembrallToggle call Remembrall_toggle()

silent call Remembrall_on()

" vim: sw=2
