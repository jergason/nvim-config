(local octo (require :octo))
(local util (require :config.util))
(local picker (require :config.picker))

(fn octo-picker-provider []
  (if (= (picker.current-backend) "snacks")
      "snacks"
      "fzf-lua"))

(octo.setup {:picker (octo-picker-provider)})

(util.nnoremap :opl "Octo pr list")
(util.nnoremap :opc "Octo pr create")
(util.nnoremap :opr "Octo review start")
(util.nnoremap :opb "Octo pr browser")
(util.nnoremap :opo "Octo pr checkout")
(util.nnoremap :opm "Octo merge squash")
