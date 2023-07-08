(module filetype.typescript {autoload {nvim aniseed.nvim}})

;; sticky context headers
(nvim.ex :TSContextEnable)
;; use treesitter for fodling
(set nvim.o.foldmethod :expr)
(set nvim.o.foldexpr "nvim_treesitter#foldexpr()")
