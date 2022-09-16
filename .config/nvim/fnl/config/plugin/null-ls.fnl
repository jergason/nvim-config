(module config.plugin.null-ls
  {autoload {null-ls null-ls}})

(null-ls.setup {:sources [;formatting
                          null-ls.builtins.formatting.prettier
                          null-ls.builtins.formatting.fnlfmt
                          null-ls.builtins.formatting.cljstyle
                          ;diagnostics
                          null-ls.builtins.diagnostics.eslint
                          null-ls.builtins.diagnostics.luacheck
                          null-ls.builtins.diagnostics.shellcheck
                          ;code actions
                          null-ls.builtins.code_actions.shellcheck
                          null-ls.builtins.code_actions.eslint
                          ]})
