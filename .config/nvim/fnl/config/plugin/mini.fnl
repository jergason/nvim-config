(local clue (require :mini.clue))
(local files (require :mini.files))
(local icons (require :mini.icons))
(local pick (require :mini.pick))
(local statusline (require :mini.statusline))
(local surround (require :mini.surround))
(local tabline (require :mini.tabline))
(local trailspace (require :mini.trailspace))

(icons.setup)
(clue.setup {:triggers [{:mode [:n :x] :keys :<Leader>}
                        {:mode :n :keys "["}
                        {:mode :n :keys "]"}
                        {:mode [:n :x] :keys :g}
                        {:mode :n :keys :<C-w>}
                        {:mode [:n :x] :keys :z}]
             :clues [(clue.gen_clues.square_brackets)
                     (clue.gen_clues.g)
                     (clue.gen_clues.windows)
                     (clue.gen_clues.z)]})

(files.setup)
(vim.api.nvim_create_autocmd :User
                             {:pattern :MiniFilesBufferCreate
                              :callback (fn [args]
                                          (let [buf-id (. (. args :data)
                                                          :buf_id)]
                                            (vim.keymap.set :n :<CR>
                                                            #(files.go_in {:close_on_file true})
                                                            {:buffer buf-id
                                                             :desc "Go in entry plus"})
                                            (vim.keymap.set :n :<Esc>
                                                            files.close
                                                            {:buffer buf-id
                                                             :desc :Close})))})

(vim.keymap.set :n "-" #(files.open (vim.api.nvim_buf_get_name 0))
                {:desc "Open file picker at current file's dir"})

(set vim.ui.select pick.ui_select)

(fn active-statusline []
  (let [(mode mode-hl) (statusline.section_mode {:trunc_width 120})
        filename (if (= vim.bo.buftype :terminal) "%t" "%f%m%r")
        git (statusline.section_git {:trunc_width 80})
        diff (statusline.section_diff {:trunc_width 75})
        diagnostics (statusline.section_diagnostics {:trunc_width 75})
        lsp (statusline.section_lsp {:trunc_width 75})
        fileinfo (statusline.section_fileinfo {:trunc_width 120})
        location (statusline.section_location {:trunc_width 75})
        search (statusline.section_searchcount {:trunc_width 75})]
    (statusline.combine_groups [{:hl mode-hl :strings [mode]}
                                {:hl :MiniStatuslineFilename
                                 :strings [filename]}
                                "%<"
                                {:hl :MiniStatuslineDevinfo
                                 :strings [git diff diagnostics lsp]}
                                "%="
                                {:hl :MiniStatuslineFileinfo
                                 :strings [fileinfo]}
                                {:hl mode-hl :strings [search location]}])))

(statusline.setup {:content {:active active-statusline}})

(surround.setup)
(tabline.setup)
(trailspace.setup)
