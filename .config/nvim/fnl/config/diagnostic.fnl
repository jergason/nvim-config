(local picker (require :config.picker))

(fn show-jumped-diagnostic [diagnostic bufnr]
  (when diagnostic
    (vim.diagnostic.open_float {:bufnr bufnr
                                :scope :line
                                :pos [diagnostic.lnum diagnostic.col]
                                :border :rounded
                                :source :if_many
                                :focusable false})))

(fn jump-diagnostic [count]
  (vim.diagnostic.jump {: count :on_jump show-jumped-diagnostic}))

(fn setup []
  (vim.keymap.set :n :<leader>le vim.diagnostic.open_float
                  {:desc "Show diagnostic"})
  (vim.keymap.set :n :<leader>lq vim.diagnostic.setqflist
                  {:desc "Send diagnostics to quickfix"})
  (vim.keymap.set :n :<leader>dj #(jump-diagnostic 1)
                  {:desc "Next diagnostic"})
  (vim.keymap.set :n :<leader>dk #(jump-diagnostic -1)
                  {:desc "Previous diagnostic"})
  (vim.keymap.set :n :<leader>ld picker.diagnostics
                  {:desc "Pick diagnostics"}))

{: setup}
