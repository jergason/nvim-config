(module config.plugin.treesitter
  {autoload {treesitter nvim-treesitter.configs}})

(treesitter.setup {:highlight {:enable true}
                   :additional_vim_regex_highlighting ["org"]
                   :indent {:enable true}
                   :ensure_installed ["clojure" "org"]})
