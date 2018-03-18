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

syntax clear
syntax match hintMode /^.../ nextgroup=hintArg
syntax match hintArg /\s/ contained nextgroup=hintMap
syntax match hintMap /[^ ]*\s/ contained nextgroup=hintScope skipwhite
syntax match hintScope /\s*[*&]\{0,1}@\{0,1}/ contained nextgroup=hintValue skipwhite
syntax match hintValue /.*$/ contained

highlight default link hintMode Type
highlight default link hintArg Character
highlight default link hintMap Constant
highlight default link hintScope Special
highlight default link hintValue Function
highlight default link hintSelected Todo
