(module config.plugin.lsp.init
        {autoload {mlp mason-lspconfig
                   null-ls config.plugin.lsp.null-ls
                   lspconfig config.plugin.lsp.lspconfig
                   fidget fidget}})

(lspconfig.setup)
(null-ls.setup)
(mlp.setup)
(fidget.setup)
