(local toggleterm (require :toggleterm))

(toggleterm.setup {:open_mapping :<leader>te
                   :direction :vertical
                   :insert_mappings false
                   :terminal_mappings false
                   :float_opts {:border :curved}
                   :winbar {:enabled true}
                   :size (fn [term]
                           (if (= term.direction :horizontal)
                               (* vim.o.lines 0.4)
                               (= term.direction :vertical)
                               (* vim.o.columns 0.4)))})
