## Visual Block

Useful for prefixing a group of lines w/ a comment for example

- `Ctrl-v` to enter "visual block" mode.
- `I` to enter insert mode (why not `i`? No idea)
- `Esc` when done, wait a sec and the text will be prefixed to all the selected lines

## `CTRL-O`

in insert mode, type `:` then you can execute a command, then return to insert mode so you don't have to go back and forth between normal and insert mode.

## `g_`

Motion to jump to end of the line without the newline. Useful for yanking a line without the newline.

## Treesitter Incremental Selection

You can use treesitter to select via AST - select next scope, parent, etc

## tags

`Ctrl-]` is the general jump-to-tag command. Useful for navigating help. Dunno how to integrate tags w/ language servers and other stuff. (UPDATE: generally, don't use tags for stuff you can use a language server for).
Need to look in to how to go to definition in clojure for example.
See `:help tag-stack` for more info on hopping around between tags, but `Ctrl-T` goes back, `:ta` goes forward
Generally useful in help, but for navigating around code there are better more syntax-aware tools.

## navigating

parens jump between sentences.
curly braces jump between paragraphs

## jumplist

List of all the places motions take you, sorta? Can jump back and forth to previous locations in the editing session. `Ctrl-o` goes forward, `Ctrl-i` goes back (I think).

## quickfix list

`:helpg pattern` searching help files and populates the quickfist list with matches. Telescope seems better for this.

- `:cn` jumps to the next item. `:cl` shows the whole list and lets you select one thing.
- `c-q` populates the qf list from telecope
- `:cfilter` lets you filter the quickfix list by a regexp
- unimpaired binds ]q and [q to navigating in the list
- https://codeinthehole.com/tips/vim-lists/ for more interesting info on lists
- `:colder` goes to older qflist
- `:cnewer` to next (via [this](https://vimtricks.com/p/vimtrick-navigate-through-quickfix/))

## neovim api stuff

- `aniseed.nvim` is actually [this](https://github.com/norcalli/nvim.lua)
- `(nvim.ex.thing arguments)` is the same as executing `:thing arguments`
- G

## `:cdo`

Execute a command on each element in the qflist. For example, `:cdo s/foo/bar/ | update` would execute the replace operation and then save on each buffer in the qflist.

### `:noautocmd`

run a command without any autocommands. Useful to stop gitgutter from choking when I do a massive CDO command

## File Browsing

### Netrw

- `%` to create a new file
- `D` to delete a file
- `<c-l>` to refresh dir listing
- tree style is your friend
- netrw makes copying/pasting files impossible?
- Changing the style seems impossible with vim-vinegar?

## Macros

- `q{register}` to record the macro
- do stuff
- `q` again to end macro recording
- `@{register}` to run the macro
- Can take motions or other things, so `3@a` runs the macro in the `a` register three times.

## K

See `:help K`. Runs a program to look up docs for the word under the cursor. Maybe this gets set to something fancy in different language modes? See `:help keywordprg`, seems like it just uses `:Man` by default.

## Terminal

nvim includes a built in terminal emulator. `:terminal` to open it. Hit an insert key to go in to insert mode. Hit `Ctrl-\ Ctrl-n` to go back to normal mode. Who needs fancy terminal toggling stuff or tmux etc etc?

## Conjure

- How to see the log? <leader>le shows it in the current buffer
- How to see values inline?
- How to just open a generic repl w/ fennel/conjure?
- `<leader>K` to look up docs
- `gd` to go to definition

## Expanding Vim variables

`vim.fn.expand('%')` will expand the current path for example.

## Filename Modifiers

`%' will turn in to the path to the current file. See `:help filename-modifiers` for the kind of stuff you can do with these. Useful ones:

- `:p` - make it an absolute path
- `:h` - strip the filename and extension to just get the directory of the currently open file

## Tabs

- `gt` - go to next tab
- `gT` - previous tab
- `tabn` = new tab I think?

## Diffing

`vim -d [files]` open files up in diff mode

- `:difft` - diff this, turn current file in to part of the diff
- `:diffs` - open file in new split, current window is part of the diff too
- `:TOHtml` - can make it easy to pretty-print and share diffs w/ folks for stuff that doesn't show up on GH

# Stuff To Look In To

## Folds

- See `:help usr_28` for the user manual on folding.
- `:set foldcolumn=auto:4` - this adds a column to the left of the screen showing folds. It'll be up to 4 characters wide to show nested folds.
- `zi` toggles all folding off and on in a buffer
- you have to create folds, and then you can open or close them or delete them.
- `zO` opens all folds at the current cursor
- `zo` opens a fold at the current cursor
- `zC` closes ALL folds at the current cursor
- `zc` closes a fold at the current cursor
- `zm` folds more (folds one more level I guess?). This affects ALL folds in a file
- `zr` reduces folds one level
  These both work by setting the `foldlevel` I guess? So you can also manually set that.

  One problem with setting the foldexpr - looks like it automatically creates and closes folds, so all files start folded

## Formatting

- `gq` is supposed to format, but seems off, and not sure how to hook it up to stuff like prettier, etc
- Update - I think I can do this through null-ls and associated plugins.

## Registers

## Undo Tree

## Autocomplete

- How to figure out how to only enable autocomplete when I ask for it? It's kinda annoying having it pop up all the time without me doing anything.
- Why are autocomplete options sometimes duplicated?

## Setting Key Mappings

There are a ton of different APIs for setting key mappings in neovim and aniseed. Which one to use when and why?

- `vim.keymap.set`
- `nvim_set_keymap`

### `<cmd>` vs `<plug>` in mappings

when do I use which one, and why? I am not sure!

## LSP integration

Unclear to me how to see and interact w/ all the LSP stuff. How do I see errors? Warnings? Type hint? Look up docs? Interact w/ a REPL?
`<leader>fr` - find all references w/ telescope

## Formatting

- use `:noa w` to write without autocommands, which disableds automatic lsp formatting, I think

## TODO

- find out how to evaluate fennel code in conjure repl
- find out how to get a clojure repl up and running
- find out how to look up documentation for a clojure function
- figure out snippets
- how to handle the annoying matching parens in lisp code. What is that coming from? How to make it smarter?
  - update: looks like it's coming from sexpr stuff
- How to filter diagnostics for just errors for example?
- look in to diagnostic signs, virtual text, etc. See https://smarttech101.com/nvim-lsp-diagnostics-keybindings-signs-virtual-texts/#severity_signs_in_nvim_lsp_diagnostics
- figure out why I'm getting a "cannot parse tsconfig.eslint.json" errors

## null-ls

Sometimes I don't want to format stuff with prettier (markdown mostly). Use `:noa w` to write without triggering autocommands, which are what trigger the null-ls formatting.

## Random Helptags Exploration

`helptags ALL` was failing b/c of a duplicate tag error. Turned out that a help file in main was removed/renamed, and installing from source doesn't remove old runtime files, only copies over new stuff. So the tag was still being generated even if I removed the tags file (which I found out was located in the runtime/docs directory. Solution was to remove runtime files completely and reinstall from scratch.

## Building neovim

- `make distclean && make clean` to remove old build artifacts
- `make CMAKE_BUILD_TYPE=RelWithDebInfo && make CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=~/neovim" install` to build and install in my local dir
