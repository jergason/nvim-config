# Neovim Config!

## Prerequisites

Things you need installed in your OS to use this setup

-   [git](https://git-scm.com/downloads)
-   [nvim](https://neovim.io/)
-   [rg](https://github.com/BurntSushi/ripgrep)

## How to use

**Make sure you backup your current configuration files in `$HOME/.config/nvim` BEFORE running this.**

Run these commands in the root of this repo:

```bash
# Delete the current nvim config
rm -rf $HOME/.config/nvim

# Makes a symbolic link to the files in this repo
ln -sf $PWD/.config/nvim $HOME/.config/nvim
```

When you start nvim for the first time it will download lazy and aniseed and show some errors. That's normal. Install the deps declared in lazy with `:Lazy install`. This will install all plugins declared in `fnl/config/plugin.fnl`. Then turn it off and on again.

## Review the current PR

On a branch with a GitHub PR, press `Space g p` or run `:DiffviewPR`.
This requires [GitHub CLI](https://cli.github.com/) authenticated with `gh auth login`.
The command reads the PR's target from GitHub, fetches its target commit, and opens
Diffview against the common ancestor with editable local files. Local edits appear
alongside committed changes. If GitHub cannot find a PR, the command reports the
error instead of choosing a default branch.
