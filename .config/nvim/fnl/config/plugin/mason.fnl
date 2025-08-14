(module config.plugin.mason
        {autoload {mason mason util config.util nvim aniseed.nvim}})

(mason.setup {:ui {:border :single}})

(def- mason-deps
  [:bash-language-server
   :clangd
   :efm
   :eslint-lsp
   ;; TOOD: do I need to manage this outside of Mason since it might depend on installed versions of golang?
   :gopls
   :lua-language-server
   :ocaml-lsp
   :pyright
   :prettier
   :rust_analyzer
   :terraform-ls
   ; :typescript-language-server
   :vtsls
   :yaml-language-server])

(defn install-mason-deps
  [required-deps]
  (each [_ dep (pairs required-deps)]
    (nvim.ex.MasonInstall dep)))

(nvim.create_user_command :MasonJergInstallAll #(install-mason-deps mason-deps)
                          {:desc "Install or update mason deps"})
