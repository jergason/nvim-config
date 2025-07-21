(module config.plugin.treesitter
        {autoload {treesitter nvim-treesitter.configs
                   ctx treesitter-context
                   pairs tree-pairs
                   nvim aniseed.nvim
                   string aniseed.string}})

; install required parsers
(local ts-parsers [:bash
                   :c
                   :comment
                   :cpp
                   :css
                   :csv
                   :diff
                   :dockerfile
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
                   :javascript
                   :jq
                   :jsdoc
                   :json
                   :lua
                   :make
                   :markdown
                   :markdown_inline
                   :python
                   :rust
                   :sql
                   :ssh_config
                   :terraform
                   :toml
                   :tsx
                   :typescript
                   :vim
                   :vimdoc
                   :xml
                   :yaml])

(nvim.create_user_command :JamisonTSUpdate
                          (.. :TSUpdateSync " " (string.join " " ts-parsers)) {})

; 300 KB
(def max-file-size (* 1024 7))

; large file stuff to look at 
; https://www.reddit.com/r/neovim/comments/12n5lvl/how_do_you_deal_with_large_files/
; https://github.com/nvim-treesitter/nvim-treesitter/pull/3570/files
; https://www.reddit.com/r/neovim/comments/xskdwc/how_to_disable_lsp_and_treesitter_for_huge_file/
; https://www.vim.org/scripts/script.php?script_id=1506

; local current_file = vim.api.nvim_buf_get_name(0) -- 0 refers to the current buffer
; local file_size = vim.fn.getfsize(current_file)
; print("File size in bytes: " .. file_size)

; disable treesitter folding for large file
(fn is-large-file [file]
  (> (vim.fn.getfsize file) max-file-size))

(fn ts-disable-large-file [lang buffer] ; (print (vim.print "Disabling treesitter for large files, is large file is"))
  ; (print (vim.print (vim.inspect (vim.api.nvim_buf_line_count buffer))))
  (> (vim.api.nvim_buf_line_count buffer) 30000))

(treesitter.setup {:highlight {:enable true :disable ts-disable-large-file}
                   ; config for treesitter-text-objects to enable swapping arguments in functions
                   ; see treesitter-text-objects docs for more info
                   :textobjects {:enable true
                                 :disable ts-disable-large-file
                                 :swap {:enable true
                                        :swap_next {:<leader>a "@parameter.inner"}
                                        :swap_previous {:<leader>A "@parameter.inner"}}}
                   :incremental_selection {:enable true
                                           :disable ts-disable-large-file}})

(ctx.setup {:separator "-" :max_lines 5 :min_window_height 20})

(pairs.setup)

