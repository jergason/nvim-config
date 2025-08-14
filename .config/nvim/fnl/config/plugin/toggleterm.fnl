(module config.plugin.toggleterm
        {autoload {toggleterm toggleterm nvim aniseed.nvim}})

(toggleterm.setup {:open_mapping :<leader>te
                   :direction :vertical
                   :insert_mappings false
                   :terminal_mappings false
                   :float_opts {:border :curved}
                   :winbar {:enabled true}
                   :size (fn [term]
                           (if (= term.direction :horizontal)
                               (* nvim.win_get_height 0.4)
                               (= term.direction :vertical)
                               (* nvim.o.columns 0.4)))})
