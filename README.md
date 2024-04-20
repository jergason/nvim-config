# Neovim Config!

## Prerequisites

Things you need installed in your OS to use this setup

- [git](https://git-scm.com/downloads)
- [nvim](https://neovim.io/)
- [rg](https://github.com/BurntSushi/ripgrep)
- [clojure-lsp](https://github.com/clojure-lsp/clojure-lsp)

## How to use

**Make sure you backup your current configuration files in `$HOME/.config/nvim` BEFORE running this.**

Run these commands in the root of this repo:

```bash
# Delete the current nvim config
rm -rf $HOME/.config/nvim

# Makes a symbolic link to the files in this repo
ln -sf $PWD/.config/nvim $HOME/.config/nvim
```

When you start nvim for the first time it will download packer and aniseed and show some errors, thats normal press enter to ignore and go to the nvim console pressing `:` and type `PackerInstall`.
This will install all plugins declared in `fnl/config/plugin.fnl`, after packer's panel showing all the plugins where installed, close nvim and open it again, no errors should show up this time.

## Plugins

- [packer](https://github.com/wbthomason/packer.nvim) _Plugin/package management_
- [aniseed](https://github.com/Olical/aniseed) _Bridges between fennel and nvim_
- [conjure](https://github.com/Olical/conjure) _Interactive repl based evaluation for nvim_
- [telescope](https://github.com/nvim-telescope/telescope.nvim) _Find, Filter, Preview, Pick_
- [treesitter](https://github.com/nvim-treesitter/nvim-treesitter) _Incremental parsing system for highlighting, indentation, or folding_
- [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) _Quickstart configurations for the Nvim LSP client_
- [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) _Autocompletion plugin_
- [github-nvim-theme](https://github.com/projekt0n/github-nvim-theme) _Github theme for Neovim_
- [tpope-vim-sexp-bundle](https://github.com/tpope/vim-sexp-mappings-for-regular-people) _sexp mappings for regular people_
- [lualine](https://github.com/nvim-lualine/lualine.nvim) _neovim statusline plugin written in pure lua_
- [luasnip](https://github.com/L3MON4D3/LuaSnip) _Snippet Engine for Neovim written in Lua._
