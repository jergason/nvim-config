(module config.plugin.vim-test {autoload {nvim aniseed.nvim}})

(nvim.set_keymap :n :<leader>tf :<cmd>TestFile<cr> {:noremap true})
(nvim.set_keymap :n :<leader>tn :<cmd>TestNearest<cr> {:noremap true})
