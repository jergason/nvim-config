(module config.plugin.orgmode
  {autoload {nvim aniseed.nvim
             orgmode orgmode }})

; Do i need more than this?
(orgmode.setup_ts_grammar)
(orgmode.setup)

;(telescope.setup {:defaults {:file_ignore_patterns ["node_modules"]}
;                  :extensions {:ui-select {1 (themes.get_dropdown {})}}
;                  :pickers {:find_files {:find_command ["rg" "--files" "--iglob" "!.git" "--hidden"]}}})
;
;(telescope.load_extension "ui-select")
;
;(nvim.set_keymap :n :<leader>ff ":lua require('telescope.builtin').find_files()<CR>" {:noremap true})
;(nvim.set_keymap :n :<leader>fg ":lua require('telescope.builtin').live_grep()<CR>" {:noremap true})
;(nvim.set_keymap :n :<leader>fb ":lua require('telescope.builtin').buffers()<CR>" {:noremap true})
;(nvim.set_keymap :n :<leader>fh ":lua require('telescope.builtin').help_tags()<CR>" {:noremap true})
