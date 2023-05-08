(module config.plugin.mason
        {autoload {mason mason
                   reg mason-registry
                   util config.util
                   nvim aniseed.nvim}})

(mason.setup {:ui {:border :single}})

(def- mason-deps
  [:arduino-language-server
   :bash-language-server
   :clojure-lsp
   :eslint-lsp
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

(def- installed-mason-deps (reg.get_installed_package_names))

(defn install-mason-deps
  [required-deps installed-deps]
  (each [_ dep (pairs required-deps)]
    (if (not (util.includes installed-deps dep))
        (nvim.ex.MasonInstall dep))))

; can I call a lua function directly here?
(nvim.create_user_command :MasonJergInstallAll
                          #(install-mason-deps mason-deps installed-mason-deps)
                          {:desc "Install all the mason things I care about"})

;; TODO: how do I bind this fennel function to a keypress? Just try . . . this?
(nvim.set_keymap :n :<leader>min :MasonInstallAll {:noremap true})

;(util.nnoremap 
;(install-mason-deps mason-deps installed-mason-deps)
