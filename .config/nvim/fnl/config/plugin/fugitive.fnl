(module config.plugin.fugitive {autoload {util config.util}})

(util.nnoremap :gx :GBrowse)
(util.nnoremap :gb "Git blame")
(util.nnoremap :gl "Git log --oneline")
(util.nnoremap :gs :Git)
