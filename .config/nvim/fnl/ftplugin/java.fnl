(module filetype.java {autoload {java config.plugin.lsp.java
                                 jdtls jdtls
                                 nvim aniseed.nvim}})

(jdtls.start_or_attach java.lsp-args)
