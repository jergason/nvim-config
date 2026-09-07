(local buffer-size (require :config.buffer-size))

(fn js-setup []
  (when (not (buffer-size.large? 0))
    (vim.cmd ":TSContext enable")
    (set vim.opt_local.foldmethod :expr)
    (set vim.opt_local.foldexpr "v:lua.vim.treesitter.foldexpr()")))

{: js-setup}
