(local lint (require :lint))

(set lint.linters_by_ft {:clojure [:clj-kondo]
                         :fennel [:fennel]
                         :javascript [:eslint]
                         :javascriptreact [:eslint]
                         :lua [:luacheck]
                         :sh [:shellcheck]
                         :typescript [:eslint]
                         :typescriptreact [:eslint]})

(local group-name :JamisonLint)
(local augroup (vim.api.nvim_create_augroup group-name {:clear true}))

(vim.api.nvim_create_autocmd :BufWritePost
                             {:group group-name
                              :pattern "*"
                              :callback #(lint.try_lint)})
