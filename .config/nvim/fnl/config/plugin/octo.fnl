(module config.plugin.octo {autoload {octo octo util config.util}})

(octo.setup)

(util.nnoremap :opl "Octo pr list")
(util.nnoremap :opcr "Octo pr create")
(util.nnoremap :opb "Octo pr browser")
(util.nnoremap :opco "Octo pr checkout")
(util.nnoremap :opm "Octo merge squash")
