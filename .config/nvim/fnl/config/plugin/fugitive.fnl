(module config.plugin.fugitive
  {autoload {util config.util}})

(util.nnoremap :gx "GBrowse")
;(util.vnoremap :gx "GBrowse")
(util.nnoremap :gb "Git blame")
(util.nnoremap :gl "Gclog")
(util.nnoremap :gs "Git")

