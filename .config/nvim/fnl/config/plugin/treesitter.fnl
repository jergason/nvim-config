(module config.plugin.treesitter
        {autoload {treesitter nvim-treesitter.configs}})

; 300 KB
; (def max-file-size (* 1024 300))
; (defn disable-treesitter-for-large-files [language buffer]
;   (let []
;     )
;   )

; large file stuff to look at 
; https://www.reddit.com/r/neovim/comments/12n5lvl/how_do_you_deal_with_large_files/
; https://github.com/nvim-treesitter/nvim-treesitter/pull/3570/files
; https://www.reddit.com/r/neovim/comments/xskdwc/how_to_disable_lsp_and_treesitter_for_huge_file/
; https://www.vim.org/scripts/script.php?script_id=1506

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
