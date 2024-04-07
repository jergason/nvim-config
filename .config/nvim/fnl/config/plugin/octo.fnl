(module config.plugin.octo {autoload {octo octo util config.util}})

(octo.setup)

(util.nnoremap :opl "Octo pr list")
(util.nnoremap :opc "Octo pr create")
(util.nnoremap :opr "Octo review start")
(util.nnoremap :opb "Octo pr browser")
(util.nnoremap :opo "Octo pr checkout")
(util.nnoremap :opm "Octo merge squash")

