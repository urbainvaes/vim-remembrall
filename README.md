# Remembrall

A small plugin that makes it easier to remember mappings.

# Installation

Using [vim-plug](https://github.com/junegunn/vim-plug):

```vim
Plug 'urbainvaes/vim-remembrall'
```

# Usage

![](https://raw.github.com/urbainvaes/vim-remembrall/gif/tty.gif)

To scroll down and up the list, use `<c-e>`, `<c-y>`, `<c-f>`, or `<c-b>`.
Adding support for a prefix can be achieved via mappings in your `.vimrc`:

```vim
" Show ',' normal mode mappings when ',' is pressed.
nnoremap <silent> <expr> , Remembrall(',')

" Show ',' normal mode mappings when the key combination ',?' is pressed,
" so we don't have to wait for the timeout.
nnoremap <silent> <expr> ,? Remembrall(',')

" Show visual mode mappings.
vnoremap <silent> <expr> ? Remembrall('v', '')
```

Remembrall defines a mapping for the all the prefixes in the list `g:remembrall_normal_keys`,
which defaults to *c, d, g, y, ], [, >, <, =, \<Leader\>* and *\<LocalLeader\>*.
A list of suffixes can be defined with `g:remembrall_suffixes`
that will be appended to the left-hand side in the definition of the mappings.

To avoid the timeout between a key press and the moment Remembrall opens,
the argument `<nowait>` can be used in the definition of the corresponding mapping.
This can be useful if you are not familiar with the keybindings of a plugin.
The following mapping, for example,
will force Remembrall to open directly when the default `vimtex` prefix,
`<LocalLeader>l`, is pressed in a `tex` buffer:
```vim
augroup remembrall
    autocmd FileType tex nnoremap <buffer> <nowait> <expr> <LocalLeader>l Remembrall(',l')
augroup END
```

# Customization

| Config                     | Default         | Description                            |
| ------                     | -------         | -----------                            |
| `g:remembrall_window`      | `topleft 30new` | Command for creating Remembrall window |
| `g:remembrall_zoom`        | `\<c-z>`        | Key to toggle zoom                     |
| `g:remembrall_search`      | `1`             | Enable search using `/`                |
| `g:remembrall_auto_accept` | `1`             | Automically accept unique match        |
| `g:remembrall_accept`      | `\<c-m>`        | Key to accept a mapping                |

# Inspiration and thanks

Some parts of the source code were inspired by [vim-peekaboo](https://github.com/junegunn/vim-peekaboo).

Many thanks to Raimond Willemsen for reporting bugs and suggesting improvements.

# License

MIT
