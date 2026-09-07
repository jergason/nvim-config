(local mason (require :mason))

(mason.setup {:ui {:border :single}})

(local mason-deps [:bash-language-server
                   :clangd
                   :efm
                   :eslint-lsp
                   :fennel-ls
                   ;; TOOD: do I need to manage this outside of Mason since it might depend on installed versions of golang?
                   :gopls
                   :lua-language-server
                   "mmdc@11.17.0"
                   :oxfmt
                   :oxlint
                   :prettier
                   :terraform-ls
                   :vtsls
                   :yaml-language-server])

(fn install-mason-deps [required-deps]
  (each [_ dep (pairs required-deps)]
    (vim.cmd (.. "MasonInstall " dep))))

(vim.api.nvim_create_user_command :MasonJergInstallAll
                                  #(install-mason-deps mason-deps)
                                  {:desc "Install or update mason deps"})
