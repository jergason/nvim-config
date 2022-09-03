(module config.plugin.octo
  {autoload {octo octo
             util config.util}})

(octo.setup)

(util.nnoremap :opl "Octo pr list")
(util.nnoremap :opc "Octo pr create")
(util.nnoremap :ob "Octo pr browser")
(util.nnoremap :opm "Octo merge squash")
