(module config.plugin.lsp.init
        {autoload {efm config.plugin.lsp.efm
                   lspconfig config.plugin.lsp.lspconfig
                   fidget fidget}})

(efm.setup)
(lspconfig.setup)
(fidget.setup)
