(module config.plugin.treesitter
        {autoload {treesitter nvim-treesitter.configs}})

; 300 KB
; (def max-file-size (* 1024 300))
; (defn disable-treesitter-for-large-files [language buffer]
;   (let []
;     )
;   )

(treesitter.setup {:highlight {:enable true}
                   :additional_vim_regex_highlighting [:org]
                   ; is this what's messing up my formatting?
                   ; :indent {:enable true }
                   :textobjects {:enable true}
                   :incremental_selection {:enable true}
                   ; :disable #(nil)
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
