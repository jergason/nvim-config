(module config.plugin.telescope
  {autoload {nvim aniseed.nvim
             telescope telescope
             util config.util
             themes telescope.themes}})

(telescope.setup {:defaults {:path_display {:shorten {:len 2 :exclude [-2 -1]}}
                             :winblend 12
                             :dynamic_preview_title true}
                  :extensions {:ui-select {1 (themes.get_dropdown {})}}
                  :pickers {:find_files {:find_command ["rg" "--files" "--iglob" "!.git" "--hidden"]}}})

(telescope.load_extension "ui-select")
(telescope.load_extension "frecency")

;; how to integrate which-key with this stuff? I'd like to automatically generate the mapping and the whichkey docs for it at the same time
(util.nnoremap :ff "Telescope find_files")
(util.nnoremap :fg "Telescope live_grep")
(util.nnoremap :fb "Telescope buffers")
(util.nnoremap :fh "Telescope help_tags")
(util.nnoremap :fw "Telescope grep_string")
(util.nnoremap :fd "Telescope diagnostics")
(util.nnoremap :fp "Telescope frecency workspace=CWD")
