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
