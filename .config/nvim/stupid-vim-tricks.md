## Visual Block

Useful for prefixing a group of lines w/ a comment for example

* `Shift-v` to enter "visual block" mode.
* `I` to enter insert mode (why not `i`? No idea)
* `Esc` when done, wait a sec and the text will be prefixed to all the selected lines

## tags
`Ctrl-]` is the general jump-to-tag command. Useful for navigating help. Dunno how to integrate tags w/ language servers and other stuff. Need to look in to how to go to definition in clojure for example.
See `:help tag-stack` for more info on hopping around between tags, but `Ctrl-T` goes back, `:ta` goes forward
Generally useful in help, but for navigating around code there are better more syntax-aware tools.

## navigating
parens jump between sentences.

## jumplist
List of all the places motions take you, sorta? Can jump back and forth to previous locations in the editing session. `Ctrl-o` goes forward, `Ctrl-i` goes back (I think).

## quickfix list
`:helpg` populates the quickfist list. `:cn` jumps to the next item. `:cl` shows the whole list and lets you select one thing.

## File Browsing
## Netrw
* `%` to create a new file
* `D` to delete a file
* tree style is your friend
* netrw makes copying/pasting files impossible?

### nnn.vim
Uses good old nnn for file picking and navigation. 

* `<leader>n` opens the file picker.
* `x` deletes a file
* `<space>` marks or unmarks a file
* `w` copies marked file (something weird happens here though)
* `h` goes up, `l` enters in to a dir

### Telescope File Browser
[Plugin](https://github.com/nvim-telescope/telescope-file-browser.nvim) here.
Maybe this replaces nnn and dang netrw
* `esc` to go in to normal mode
* `c` - creates a file
* `r` - rename file
* `y` - copy selected file

## Macros
* `q{register}` to record the macro
* do stuff
* `q` again to end macro recording
* `@{register}` to run the macro
* Can take motions or other things, so `3@a` runs the macro in the `a` register three times.

## K
See `:help K`. Runs a program to look up docs for the word under the cursor. Maybe this gets set to something fancy in different language modes? See `:help keywordprg`, seems like it just uses `:Man` by default.

## Terminal
nvim includes a built in terminal emulator. `:terminal` to open it. Hit an insert key to go in to insert mode. Hit `Ctrl-\ Ctrl-n` to go back to normal mode. Who needs fancy terminal toggling stuff or tmux etc etc?

## Conjure
* How to see the log? <leader>le shows it in the current buffer
* How to see values inline?
* How to just open a generic repl w/ fennel/conjure?
* `<leader>K` to look up docs
* `gd` to go to definition

## Expanding Vim variables
`vim.fn.expand('%')` will expand the current path for example.

## Filename Modifiers
`%' will turn in to the path to the current file. See `:help filename-modifiers` for the kind of stuff you can do with these. Useful ones:
* `:p` - make it an absolute path
* `:h` - strip the filename and extension to just get the directory of the currently open file

## Tabs
* `gt` - go to next tab
* `gT` - previous tab
* `tabn` = new tab I think?

# Stuff To Look In To

## Folds

## Formatting


## Registers

## Undo Tree

## Autocomplete

## LSP integration
Unclear to me how to see and interact w/ all the LSP stuff. How do I see errors? Warnings? Type hint? Look up docs? Interact w/ a REPL?
`<leader>fr` - find all references w/ telescope

## Treesitter Incremental Selection
You can use treesitter to select via AST - select next scop, parent, etc
