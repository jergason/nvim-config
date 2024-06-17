(module config.plugin.mason
        {autoload {mason mason util config.util nvim aniseed.nvim}})

(mason.setup {:ui {:border :single}})

(def- mason-deps
  [:arduino-language-server
   :bash-language-server
   :clojure-lsp
   :efm
   :eslint-lsp
   ;; TOOD: do I need to manage this outside of Mason since it might depend on installed versions of golang?
   :gopls
   :graphql-language-service-cli
   :jdtls
   :joker
   :lua-language-server
   :prettier
   :pyright
   :terraform-ls
   :typescript-language-server
   :yaml-language-server])

(defn install-mason-deps
  [required-deps]
  (each [_ dep (pairs required-deps)]
    (nvim.ex.MasonInstall dep)))

(nvim.create_user_command :MasonJergInstallAll #(install-mason-deps mason-deps)
                          {:desc "Install or update mason deps"})

