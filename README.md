# Remembrall

This is a small plugin that makes it easier to remember mappings.

## Installation

Using [vim-plug](https://github.com/junegunn/vim-plug):

```vim
Plug 'urbainvaes/vim-remembrall'
```

## Usage

![](https://raw.github.com/urbainvaes/vim-remembrall/gif/tty.gif)

To scroll down and up the list, use `<c-e>`, `<c-y>`, or (pagewise) `<c-f>` and `<c-b>`.
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
A list of suffixes,
which will be appended to the left-hand side in the definition of the mappings,
can be defined with `g:remembrall_suffixes`.
For example, if this list is set to `["?"]`,
then the plugin will append the character `?` in the left-hand side of all the mappings it defines.
The relevant part of the plugin code should make this clear:
```vim
    for suffix in s:suffixes
      for key in s:normal_keys
        silent execute "nnoremap <silent> <expr>" key.suffix "Remembrall('".key."')"
      endfor
    endfor
```

To avoid the timeout between a key press and the moment Remembrall opens,
the argument `<nowait>` can be used in the definition of the corresponding mapping.
The following mapping, for example,
will force Remembrall to open directly when the default `vimtex` prefix,
`<LocalLeader>l`, is pressed in a `tex` buffer:
```vim
augroup remembrall
    autocmd FileType tex nnoremap <buffer> <nowait> <expr> <LocalLeader>l Remembrall(',l')
augroup END
```

## Customization

| Config                     | Default         | Description                                          |
| ------                     | -------         | -----------                                          |
| `g:remembrall_normal_keys` | See above       | Keys for which to enable Remembrall                  |
| `g:remembrall_suffixes`    | [""]            | List of suffixes                                     |
| `g:remembrall_window`      | `topleft 30new` | Command for creating Remembrall window               |
| `g:remembrall_zoom`        | `\<c-z>`        | Key to toggle zoom                                   |
| `g:remembrall_search`      | `1`             | Enable search using `/`                              |
| `g:remembrall_auto_accept` | `1`             | Automically accept unique match                      |
| `g:remembrall_accept`      | `\<c-m>`        | Key to accept a mapping when auto-accept is disabled |

## Acknowledgements

Some parts of the source code were inspired by [vim-peekaboo](https://github.com/junegunn/vim-peekaboo).
I thank Raimond Willemsen for reporting bugs and suggesting improvements.

## License

MIT
