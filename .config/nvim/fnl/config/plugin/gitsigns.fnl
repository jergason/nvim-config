(module config.plugin.gitsigns {autoload {gitsigns gitsigns nvim aniseed.nvim}})

(defn set-keymaps
  [bufnum]
  (vim.keymap.set :n :<leader>ghq (fn [] (gitsigns.setqflist 0))
                  {:buffer bufnum :noremap true}))

(gitsigns.setup {:on_attach set-keymaps})

