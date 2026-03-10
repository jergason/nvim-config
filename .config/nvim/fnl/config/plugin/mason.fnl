(local mason (require :mason))
(local util (require :config.util))

(mason.setup {:ui {:border :single}})

(local mason-deps
  [:bash-language-server
   :clangd
   :efm
   :eslint-lsp
   ;; TOOD: do I need to manage this outside of Mason since it might depend on installed versions of golang?
   :gopls
   :lua-language-server
   :ocaml-lsp
   :oxfmt
   :oxlint
   :pyright
   :prettier
   :rust_analyzer
   :terraform-ls
   ; :typescript-language-server
   :vtsls
   :yaml-language-server])

(fn install-mason-deps [required-deps]
  (each [_ dep (pairs required-deps)]
    (vim.cmd (.. "MasonInstall " dep))))

(vim.api.nvim_create_user_command :MasonJergInstallAll #(install-mason-deps mason-deps)
                                  {:desc "Install or update mason deps"})
