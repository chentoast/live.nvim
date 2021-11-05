## live.nvim

Like the name suggests, live.nvim implements live preview of the `:norm`, `:global` and `:vglobal` commands in vim, providing a
multiple cursors like experience in base Neovim.

## Installation

With your favorite package manager, like vim-plug or packer.

## Usage

Put the following in your init.vim or init.lua:

`require'live'.setup()`

Then, `:norm`, `:global`, and `:vglobal` commands will work just as you expect: the neovim buffer will update every time
you type a key. Pressing enter will confirm the command, pressing escape or Ctrl-C will undo the command.

## Acknowledgements

This plugin is essential a slightly more modern version of nvim-incnormal. Most of the hard work was done by bfredl; I just
ported it to lua and updated it with some more modern neovim features:

- Using `vim.on_key` and `vim.schedule` instead of abusing `g:Nvim_color_cmdline` and timers
- Cursor drawing with ephemeral extmarks and decoration providers instead of `nvim_buf_add_highlight`
- Support for :global and :vglobal
