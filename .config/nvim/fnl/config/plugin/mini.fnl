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

(files.setup {:options {:use_as_default_explorer true}})
(vim.keymap.set :n "-" #(files.open) {:desc "Open file picker"})

(set vim.ui.select pick.ui_select)
(surround.setup)
(tabline.setup)
(trailspace.setup)
