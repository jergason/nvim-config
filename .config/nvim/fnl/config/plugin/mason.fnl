(module config.plugin.mason
  {autoload {mason mason
             reg mason-registry
             nvim aniseed.nvim}})

(mason.setup)

(def mason-deps [:typescript-language-server :clojure-lsp :lua-language-server])
(def installed-mason-deps (reg.get_installed_package_names))

; TODO: how do I just ... run this in the REPL
(defn includes [element list index]
  (match (next list index)
    (i element) true
    i (includes element list i)))

(defn install-mason-deps [required-deps installed-deps]
  (each [_ dep  (pairs required-deps)]
    (if (not (includes dep installed-deps))
      (nvim.ex.MasonInstall dep))))

(install-mason-deps mason-deps installed-mason-deps)
