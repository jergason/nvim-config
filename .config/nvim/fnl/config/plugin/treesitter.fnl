(module config.plugin.treesitter
        {autoload {treesitter nvim-treesitter.configs
                   ctx treesitter-context
                   pairs tree-pairs
                   nvim aniseed.nvim
                   string aniseed.string}})

; install required parsers
(local ts-parsers [:bash
                   :c
                   :clojure
                   :comment
                   :cpp
                   :css
                   :csv
                   :diff
                   :dockerfile
                   :elixir
                   :elm
                   :erlang
                   :fennel
                   :git_config
                   :git_rebase
                   :gitattributes
                   :gitcommit
                   :gitignore
                   :go
                   :graphql
                   :hcl
                   :html
                   :java
                   :javascript
                   :jq
                   :jsdoc
                   :json
                   :lua
                   :make
                   :markdown
                   :markdown_inline
                   :ocaml
                   :ocaml_interface
                   :promql
                   :purescript
                   :python
                   :ruby
                   :rust
                   :scheme
                   :sql
                   :ssh_config
                   :terraform
                   :toml
                   :tsx
                   :typescript
                   :vim
                   :vimdoc
                   :xml
                   :yaml
                   :zig])

(nvim.create_user_command :JamisonTSUpdate
                          (.. :TSUpdateSync " " (string.join " " ts-parsers)) {})

; 300 KB
(def max-file-size (* 1024 300))

; large file stuff to look at 
; https://www.reddit.com/r/neovim/comments/12n5lvl/how_do_you_deal_with_large_files/
; https://github.com/nvim-treesitter/nvim-treesitter/pull/3570/files
; https://www.reddit.com/r/neovim/comments/xskdwc/how_to_disable_lsp_and_treesitter_for_huge_file/
; https://www.vim.org/scripts/script.php?script_id=1506

(fn disable-for-large-files [lang buffer]
  (let [[ok stats] (pcall vim.loop.fs_stat (vim.api.nvim_buf_get_name buffer))]
    (and ok (> (. stats :filesize) max-file-size))))

(treesitter.setup {:highlight {:enable true}
                   ; config for treesitter-text-objects to enable swapping arguments in functions
                   ; see treesitter-text-objects docs for more info
                   :textobjects {:enable true
                                 :swap {:enable true
                                        :swap_next {:<leader>a "@parameter.inner"}
                                        :swap_previous {:<leader>A "@parameter.inner"}}}
                   :incremental_selection {:enable true}
                   :disable disable-for-large-files})

(ctx.setup {:separator "-" :max_lines 5 :min_window_height 20})

(pairs.setup)

