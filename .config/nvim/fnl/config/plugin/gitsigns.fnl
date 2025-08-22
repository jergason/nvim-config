(module config.plugin.gitsigns {autoload {gitsigns gitsigns nvim aniseed.nvim}})

(def prefix :<leader>gs)

; make it easy to change the prefix later
(defn make-mapping [str] (.. prefix str))

(defn set-keymaps
  [bufnum]
  (vim.keymap.set :n (make-mapping :q) (fn [] (gitsigns.setqflist 0))
                  {:buffer bufnum :noremap true :desc "Gitsigns: set qflist"})
  (vim.keymap.set :n (make-mapping :s) (fn [] (gitsigns.stage_hunk))
                  {:buffer bufnum :noremap true :desc "Gitsigns: stage hunk"})
  (vim.keymap.set :n (make-mapping :u) (fn [] (gitsigns.undo_stage_hunk))
                  {:buffer bufnum :noremap true :desc "Gitsigns: unstage hunk"})
  (vim.keymap.set :n (make-mapping :x) (fn [] (gitsigns.reset_hunk))
                  {:buffer bufnum :noremap true :desc "Gitsigns: reset hunk"})
  (vim.keymap.set :n (make-mapping :j) (fn [] (gitsigns.next_hunk))
                  {:buffer bufnum
                   :noremap true
                   :desc "Gitsigns: jump to next hunk"})
  (vim.keymap.set :n (make-mapping :k) (fn [] (gitsigns.prev_hunk))
                  {:buffer bufnum
                   :noremap true
                   :desc "Gitsigns: jump to prev hunk"})
  (vim.keymap.set :n (make-mapping :b)
                  (fn [] (gitsigns.toggle_current_line_blame))
                  {:buffer bufnum
                   :noremap true
                   :desc "Gitsigns: Toggle Current Line Blame"}))

(gitsigns.setup {:on_attach set-keymaps})
