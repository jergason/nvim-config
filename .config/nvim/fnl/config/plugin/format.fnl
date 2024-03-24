(module config.plugin.format {autoload {conform conform}})

(conform.setup {:formatters_by_ft {:fennel [:fnlfmt]
                                   :go [:gofmt]
                                   :javascript [:prettier]
                                   :javascriptreact [:prettier]
                                   :markdown [:injected :prettier]
                                   :terraform [:terraform_fmt]
                                   :typescript [:prettier]
                                   :typescriptreact [:prettier]}
                :log_level vim.log.levels.debug
                :formatters {:fnlfmt {:command :fnlfmt :args ["-"]}}
                :format_on_save {:timeout_ms 500 :lsp_fallback true}})
