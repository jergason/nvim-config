(module config.plugin.neominimap {autoload {nvim aniseed.nvim}})

(vim.keymap.set :n :<leader>no "<cmd>Neominimap on<CR>"
                {:desc "Enable minimap globally"})

(vim.keymap.set :n :<leader>nt "<cmd>Neominimap winToggle<CR>"
                {:desc "Toggle minimap for this window"})

(set vim.g.neominimap {:auto_enable true
                       :exclude_filetypes [:codecompanion :help]
                       :mark {:enabled true}})

(def- augroup (nvim.create_augroup :NeoMiniap {:clear true}))
(nvim.create_autocmd :WinNew {:callback (fn [] (vim.cmd "Neominimap winOff"))
                              :group augroup})

