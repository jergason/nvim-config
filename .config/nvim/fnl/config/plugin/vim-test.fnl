(module config.plugin.vim-test {autoload {nvim aniseed.nvim}})

(nvim.set_keymap :n :<leader>tt :<cmd>TestFile<cr> {:noremap true})
