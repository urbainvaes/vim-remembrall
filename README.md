# Remembrall

A small pluggin to make it easier to remember mappings.

# Installation

Using [vim-plug](https://github.com/junegunn/vim-plug):

```vim
Plug 'urbainvaes/vim-remembrall'
```

# Usage

![](https://raw.github.com/urbainvaes/vim-remembrall/gif/tty.gif)

To scroll the list, use `<c-e>`, `<c-y>`, `<c-f>`, or `<c-b>`.
Adding support for a prefix can be done by adding mappings to your `.vimrc`:

```vim
" Show ',' normal mode mappings when key ',' is pressed
nnoremap <silent> <expr> , Remembrall('n', ',')

" Show ',' normal mode mappings when the key combination ',?' is pressed,
" so we don't have to wait for the timeout.
nnoremap <silent> <expr> ,? Remembrall('n', ',')

" Show visual mode mappings
vnoremap <silent> <expr> ? Remembrall('v', '')
```

Remembrall defines a mapping for the all the prefixes in the list `g:remembrall_normal_keys`,
which defaults to *c, d, g, y, ], [, >, <, =, \<Leader\>* and *\<LocalLeader\>*.
A list of suffixes can be defined with `g:remembrall_suffixes`
that will be appended to the left-hand side in the definition of the mappings.
For example, `let g:remembrall_suffixes = ["", "?"]` will cause Remembrall to define the mappings
```vim
nnoremap <silent> <expr> x Remembrall('n', ',')
nnoremap <silent> <expr> x? Remembrall('n', ',')
```
for all `x` in `g:remembrall_normal_keys`.

To avoid the timeout between a key press and the moment Remembrall opens,
the argument `<nowait>` can be used in the definition of the corresponding mapping.
This can be useful if you are not familiar with the keybindings of a plugin.
The following mapping, for example,
will force Remembrall to open directly every time the default `vimtex` prefix,
`<LocalLeader>l`, is pressed in a `tex` buffer:
```vim
augroup remembrall
    autocmd FileType tex nnoremap <buffer> <nowait> <expr> <LocalLeader>l Remembrall('n', ',l')
augroup END
```

# Customization

| Config                | Default         | Description                            |
| ------                | -------         | -----------                            |
| `g:remembrall_window` | `topleft 30new` | Command for creating Remembrall window |
| `g:remembrall_zoom`   | `\<c-z>`        | Key to toggle zoom                     |
| `g:remembrall_accept` | `\<c-m>`        | Key to accept a mapping                |
| `g:remembrall_search` | `1`             | Enable search using `/`                |

The last option is useful only in the case of nested mappings.

# Inspiration

Some parts of the source code were inspired by [vim-peekaboo](https://github.com/junegunn/vim-peekaboo).

# License

MIT
