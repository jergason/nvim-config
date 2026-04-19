(local octo (require :octo))
(local util (require :config.util))

(fn octo-picker-provider [] "default")

(octo.setup {:picker (octo-picker-provider)})

(util.nnoremap :opl "Octo pr list")
(util.nnoremap :opc "Octo pr create")
(util.nnoremap :opr "Octo review start")
(util.nnoremap :opb "Octo pr browser")
(util.nnoremap :opo "Octo pr checkout")
(util.nnoremap :opm "Octo merge squash")
