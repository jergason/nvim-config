(local treesitter (require :nvim-treesitter))
(local ctx (require :treesitter-context))
(local pairs (require :tree-pairs))
(local ts-swap (require :nvim-treesitter-textobjects.swap))

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
                   :ini
                   :javascript
                   :jq
                   :jsdoc
                   :json
                   :lua
                   :make
                   :markdown
                   :markdown_inline
                   :mermaid
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

(vim.api.nvim_create_user_command :JamisonTSUpdate
                                  (fn []
                                    (let [task (treesitter.update ts-parsers
                                                                  {:summary true})]
                                      (task:wait 300000)))
                                  {})

(vim.api.nvim_create_user_command :JamisonTSInstall
                                  (fn []
                                    (let [task (treesitter.install ts-parsers
                                                                   {:summary true})]
                                      (task:wait 300000)))
                                  {})

; large file stuff to look at
; https://www.reddit.com/r/neovim/comments/12n5lvl/how_do_you_deal_with_large_files/
; https://github.com/nvim-treesitter/nvim-treesitter/pull/3570/files
; https://www.reddit.com/r/neovim/comments/xskdwc/how_to_disable_lsp_and_treesitter_for_huge_file/
; https://www.vim.org/scripts/script.php?script_id=1506

(fn ts-disable-large-file [lang buffer] ; (print (vim.print "Disabling treesitter for large files, is large file is"))
  ; (print (vim.print (vim.inspect (vim.api.nvim_buf_line_count buffer))))
  (> (vim.api.nvim_buf_line_count buffer) 30000))

(fn ts-highlight-active? [buf]
  (let [active (vim.tbl_get vim :treesitter :highlighter :active)]
    (if active
        (. active buf)
        false)))

(fn ts-parser-active? [buf]
  (let [result [(pcall vim.treesitter.get_parser buf nil {:error false})]
        ok (. result 1)
        parser (. result 2)]
    (and ok (not= parser nil))))

(fn ts-healthy? [buf]
  (and (ts-highlight-active? buf)
       (ts-parser-active? buf)))

(fn maybe-start-treesitter [buf]
  (let [buftype (vim.api.nvim_get_option_value :buftype {:buf buf})
        filetype (vim.api.nvim_get_option_value :filetype {:buf buf})]
    (when (and (= buftype "")
               (not= filetype "")
               (not (ts-disable-large-file nil buf))
               (not (ts-healthy? buf)))
      (let [result [(pcall vim.treesitter.start buf)]
            ok (. result 1)
            syntax (vim.api.nvim_get_option_value :syntax {:buf buf})]
        (when (and (not ok)
                   (= syntax ""))
          (vim.api.nvim_set_option_value :syntax filetype {:buf buf}))))))

(vim.api.nvim_create_autocmd [:FileType :BufReadPost :BufEnter]
                             {:pattern "*"
                              :desc "Enable treesitter highlighting"
                              :callback (fn [args]
                                          (maybe-start-treesitter args.buf))})

(vim.api.nvim_create_user_command :JamisonTSBufDebug
                                  (fn [opts]
                                    (let [buf (if (= opts.args "")
                                                  (vim.api.nvim_get_current_buf)
                                                  (tonumber opts.args))
                                          filetype (vim.api.nvim_get_option_value :filetype {:buf buf})
                                          syntax (vim.api.nvim_get_option_value :syntax {:buf buf})]
                                      (vim.notify
                                       (vim.inspect {:buf buf
                                                     :filetype filetype
                                                     :syntax syntax
                                                     :highlighter (ts-highlight-active? buf)
                                                     :parser (ts-parser-active? buf)}))))
                                  {:nargs "?"})

(vim.keymap.set :n :<leader>a
                (fn []
                  (when (not (ts-disable-large-file nil 0))
                    (ts-swap.swap_next "@parameter.inner"))))

(vim.keymap.set :n :<leader>A
                (fn []
                  (when (not (ts-disable-large-file nil 0))
                    (ts-swap.swap_previous "@parameter.inner"))))

(ctx.setup {:separator "-" :max_lines 5 :min_window_height 20})

(pairs.setup)
