(module config.plugin.telescope
        {autoload {nvim aniseed.nvim
                   telescope telescope
                   tb telescope.builtin
                   util config.util
                   themes telescope.themes}})

(telescope.setup {:defaults {:path_display {:shorten {:len 3 :exclude [-2 -1]}}
                             :winblend 12
                             :prompt_prefix " "
                             :selection_caret " "
                             :preview {:filesize_limit 5}}
                  :extensions {:ui-select {1 (themes.get_dropdown {})}}
                  :pickers {:find_files {:find_command [:rg
                                                        :--files
                                                        :--iglob
                                                        :!.git
                                                        :--hidden]}
                            :current_buffer_fuzzy_find {:sorting_strategy :ascending}
                            ; search hidden dirs that aren't gitignored
                            :live_grep {:additional_args [:--hidden]}}})

(telescope.load_extension :ui-select)
(telescope.load_extension :fzf)

(util.nnoremap :ff "Telescope find_files")
(util.nnoremap :fg "Telescope live_grep")
(util.nnoremap :fb "Telescope buffers")
(util.nnoremap :fh "Telescope help_tags")
(util.nnoremap :fw "Telescope grep_string")
(util.nnoremap :fd "Telescope diagnostics")
(util.nnoremap :fc "Telescope commands")
(util.nnoremap :th "Telescope history")
(nvim.set_keymap :n :<C-/> "<cmd>Telescope current_buffer_fuzzy_find<cr>"
                 {:desc "fuzzy find in buffer"})

; helpers to edit files I often want to edit
(vim.keymap.set :n :<leader>en
                #(tb.find_files {:cwd "~/.config/nvim" :path_display [:smart]})
                {:desc "Edit neovim config"})

; TODO: make this expand file paths?
;(vim.keymap.set :n :<leader>ep "Telescope find_files cwd=~/.local/share/nvim/site/pack/packer/start" {:desc "Search plugin files"})
(vim.keymap.set :n :<leader>ep
                #(tb.find_files {:cwd "~/.local/share/nvim/site/pack/packer/start"
                                 :path_display [:smart]})
                {:desc "Search plugin files"})
