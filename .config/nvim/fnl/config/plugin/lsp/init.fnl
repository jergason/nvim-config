(local efm (require :config.plugin.lsp.efm))
(local lspconfig (require :config.plugin.lsp.lspconfig))
(local fidget (require :fidget))

(efm.setup)
(lspconfig.setup)
(fidget.setup)
