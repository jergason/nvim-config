(vim.keymap.set :n :<leader>no "<cmd>Neominimap Enable<CR>"
                {:desc "Enable minimap globally"})

(vim.keymap.set :n :<leader>nt "<cmd>Neominimap BufToggle<CR>"
                {:desc "Toggle minimap for the current buffer"})

(set vim.g.neominimap {:auto_enable false
                       :exclude_filetypes [:help :text :netrw]
                       :mini_diff {:enabled true}
                       :mark {:enabled true}
                       :window_border :double})

(local augroup (vim.api.nvim_create_augroup :NeoMiniap {:clear true}))
(vim.api.nvim_create_autocmd :WinNew {:callback (fn []
                                                  (vim.cmd "Neominimap WinDisable"))
                                      :group augroup})
