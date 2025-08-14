(module config.plugin.gitsigns {autoload {gitsigns gitsigns nvim aniseed.nvim}})

(defn set-keymaps
  [bufnum]
  (vim.keymap.set :n :<leader>ghq (fn [] (gitsigns.setqflist 0))
                  {:buffer bufnum :noremap true :desc "Gitsigns: set qflist"})
  (vim.keymap.set :n :<leader>ghs (fn [] (gitsigns.stage_hunk))
                  {:buffer bufnum :noremap true :desc "Gitsigns: stage hunk"})
  (vim.keymap.set :n :<leader>ghu (fn [] (gitsigns.undo_stage_hunk))
                  {:buffer bufnum :noremap true :desc "Gitsigns: unstage hunk"})
  (vim.keymap.set :n :<leader>ghx (fn [] (gitsigns.reset_hunk))
                  {:buffer bufnum :noremap true :desc "Gitsigns: reset hunk"})
  (vim.keymap.set :n :<leader>ghj (fn [] (gitsigns.next_hunk))
                  {:buffer bufnum
                   :noremap true
                   desc "Gitsigns: jump to next hunk"})
  (vim.keymap.set :n :<leader>ghk (fn [] (gitsigns.prev_hunk))
                  {:buffer bufnum
                   :noremap true
                   desc "Gitsigns: jump to prev hunk"})
  (vim.keymap.set :n :<leader>ghb (fn [] (gitsigns.toggle_current_line_blame))
                  {:buffer bufnum
                   :noremap true
                   :desc "Gitsigns: Toggle Current Line Blame"}))

(gitsigns.setup {:on_attach set-keymaps})

; Gitsigns toggle_current_line_blame will show inline blame
