(module config.plugin.treesitter
        {autoload {treesitter nvim-treesitter.configs}})

(treesitter.setup {:highlight {:enable true}
                   :additional_vim_regex_highlighting [:org]
                   ; is this what's messing up my formatting?
                   ; :indent {:enable true }
                   :textobjects {:enable true}
                   :incremental_selection {:enable true}
                   :ensure_installed [:bash
                                      :c
                                      :clojure
                                      :dart
                                      :fennel
                                      :go
                                      :graphql
                                      :haskell
                                      :javascript
                                      :lua
                                      :markdown
                                      :org
                                      :rust
                                      :typescript]})
