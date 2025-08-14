(module ftplugin.utilities {autoload {nvim aniseed.nvim}})

(defn js-setup
  []
  ;; sticky context headers
  ;; use treesitter for folding
  ;(print "RUNNING FTPLUGIN FOR JS-ISH LANGUAGES")
  (when (< (vim.api.nvim_buf_line_count 0) 30000) ; (print "GOT A SMALL FILE, SETTING STUFF UP")
    (nvim.command ":TSContext enable")
    (set vim.opt_local.foldmethod :expr)
    (set vim.opt_local.foldexpr "nvim_treesitter#foldexpr()")))

