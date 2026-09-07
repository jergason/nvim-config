(local treesitter (require :nvim-treesitter))
(local ctx (require :treesitter-context))
(local ts-swap (require :nvim-treesitter-textobjects.swap))
(local buffer-size (require :config.buffer-size))
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

(fn ts-highlight-active? [buf]
  (let [active (vim.tbl_get vim :treesitter :highlighter :active)]
    (if active
        (. active buf) false)))

(fn ts-parser-active? [buf]
  (let [result [(pcall vim.treesitter.get_parser buf nil {:error false})]
        ok (. result 1)
        parser (. result 2)]
    (and ok (not= parser nil))))

(fn ts-healthy? [buf]
  (and (ts-highlight-active? buf) (ts-parser-active? buf)))

(fn maybe-start-treesitter [buf]
  (let [buftype (vim.api.nvim_get_option_value :buftype {: buf})
        filetype (vim.api.nvim_get_option_value :filetype {: buf})]
    (when (and (= buftype "") (not= filetype "")
               (not (buffer-size.large? buf)) (not (ts-healthy? buf)))
      (let [result [(pcall vim.treesitter.start buf)]
            ok (. result 1)
            syntax (vim.api.nvim_get_option_value :syntax {: buf})]
        (when (and (not ok) (= syntax ""))
          (vim.api.nvim_set_option_value :syntax filetype {: buf}))))))

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
                                          filetype (vim.api.nvim_get_option_value :filetype
                                                                                  {: buf})
                                          syntax (vim.api.nvim_get_option_value :syntax
                                                                                {: buf})]
                                      (vim.notify (vim.inspect {: buf
                                                                : filetype
                                                                : syntax
                                                                :highlighter (ts-highlight-active? buf)
                                                                :parser (ts-parser-active? buf)}))))
                                  {:nargs "?"})

(vim.keymap.set :n :<leader>a
                (fn []
                  (when (not (buffer-size.large? 0))
                    (ts-swap.swap_next "@parameter.inner"))))

(vim.keymap.set :n :<leader>A
                (fn []
                  (when (not (buffer-size.large? 0))
                    (ts-swap.swap_previous "@parameter.inner"))))

(ctx.setup {:separator "-" :max_lines 5 :min_window_height 20
            :on_attach #(not (buffer-size.large? $1))})
