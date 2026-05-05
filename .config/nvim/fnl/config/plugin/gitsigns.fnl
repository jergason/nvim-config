(local gitsigns (require :gitsigns))

(local prefix :<leader>gs)
(local attach-group :JamisonGitsignsAttach)

; make it easy to change the prefix later
(fn make-mapping [str] (.. prefix str))

(fn normal-file-buffer? [buf]
  (let [name (vim.api.nvim_buf_get_name buf)
        buftype (vim.api.nvim_get_option_value :buftype {: buf})]
    (and (= buftype "") (not= name "") (= (vim.fn.filereadable name) 1))))

(fn set-keymaps [bufnum]
  (vim.keymap.set :n (make-mapping :q) (fn [] (gitsigns.setqflist 0))
                  {:buffer bufnum :noremap true :desc "Gitsigns: set qflist"})
  (vim.keymap.set :n (make-mapping :s) (fn [] (gitsigns.stage_hunk))
                  {:buffer bufnum :noremap true :desc "Gitsigns: stage hunk"})
  (vim.keymap.set :n (make-mapping :u) (fn [] (gitsigns.undo_stage_hunk))
                  {:buffer bufnum :noremap true :desc "Gitsigns: unstage hunk"})
  (vim.keymap.set :n (make-mapping :x) (fn [] (gitsigns.reset_hunk))
                  {:buffer bufnum :noremap true :desc "Gitsigns: reset hunk"})
  (vim.keymap.set :n (make-mapping :d) (fn [] (gitsigns.diffthis))
                  {:buffer bufnum
                   :noremap true
                   :desc "Gitsigns: open diff inline"}) ; navigating hunks
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

(gitsigns.setup {:auto_attach false :on_attach set-keymaps})

(vim.api.nvim_create_augroup attach-group {:clear true})

(vim.api.nvim_create_autocmd [:BufRead :BufNewFile :BufWritePost :BufFilePost]
                             {:group attach-group
                              :desc "Attach gitsigns to real file buffers"
                              :callback (fn [args]
                                          (when (normal-file-buffer? args.buf)
                                            (gitsigns.attach {:bufnr args.buf
                                                              :trigger args.event})))} )

(each [_ buf (ipairs (vim.api.nvim_list_bufs))]
  (when (and (vim.api.nvim_buf_is_loaded buf) (normal-file-buffer? buf))
    (gitsigns.attach {:bufnr buf :trigger :setup})))
