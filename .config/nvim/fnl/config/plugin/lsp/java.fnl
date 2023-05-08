(module config.plugin.lsp.java
        {autoload {nvim aniseed.nvim lspconfig config.plugin.lsp.lspconfig}})

(def lsp-args (lspconfig.make-setup-args))
