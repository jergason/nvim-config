(local clue (require :mini.clue))
(local files (require :mini.files))
(local pick (require :mini.pick))
(local surround (require :mini.surround))
(local tabline (require :mini.tabline))
(local trailspace (require :mini.trailspace))

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
(surround.setup)
(tabline.setup)
(trailspace.setup)
