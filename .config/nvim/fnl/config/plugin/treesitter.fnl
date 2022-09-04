(module config.plugin.treesitter
  {autoload {treesitter nvim-treesitter.configs}})

(treesitter.setup {:highlight {:enable true}
                   :additional_vim_regex_highlighting ["org"]
                   :indent {:enable true }
                   :textobjects {:enable true}
                   :incremental_selection {:enable true}
                   :ensure_installed ["clojure" "org" "fennel" "dart" "rust"
                                      "javascript" "typescript" "lua" "go"
                                      "graphql" "c" "bash" "haskell"]})
