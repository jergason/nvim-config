(module ftplugin.utilities {autoload {nvim aniseed.nvim}})

(defn js-setup []
  ;; sticky context headers
  (nvim.command ":TSContextEnable")
  ;; use treesitter for folding
  (set vim.opt_local.foldmethod :expr)
  (set vim.opt_local.foldexpr "nvim_treesitter#foldexpr()"))
