(local luacheck (require :efmls-configs.linters.luacheck))
(local shellcheck (require :efmls-configs.linters.shellcheck))
(local fnlfmt (require :efmls-configs.formatters.fnlfmt))
(local gofmt (require :efmls-configs.formatters.gofmt))
(local prettier (require :efmls-configs.formatters.prettier))
(local terraform_fmt (require :efmls-configs.formatters.terraform_fmt))
(local fs (require :efmls-configs.fs))
(local lspconfig-util (require :lspconfig.util))
(local lspconfig-setup (require :config.plugin.lsp.lspconfig))

; efm is used for formatting on save
; sometimes it doesn't work and i don't know why ;_;
; https://github.com/creativenull/efmls-configs-nvim/tree/main?tab=readme-ov-file#format-on-save
(local formatting-group-name :LspFormatting)

(fn formatter-client? [client]
  (or (= client.name :efm)
      (= client.name :efm_prettier)
      (= client.name :efm_oxfmt)))

(fn make-format-augroup []
  (vim.api.nvim_create_augroup formatting-group-name {}))

(fn lsp-format []
  (vim.lsp.buf.format {:filter formatter-client?}))

(fn create-formatting-autocmd []
  (vim.api.nvim_clear_autocmds {:group formatting-group-name})
  (vim.api.nvim_create_autocmd :BufWritePre
                               {:group formatting-group-name
                                :callback #(lsp-format)}))

(local oxfmt
  {:formatCommand (string.format "%s --stdin-filepath '${INPUT}'"
                                 (fs.executable :oxfmt fs.Scope.NODE))
   :formatStdin true
   :requireMarker true
   :rootMarkers [:.oxfmtrc.json
                 :oxfmt.config.ts
                 :oxfmt.config.js
                 :oxfmt.config.mjs
                 :oxfmt.config.cjs]})

(fn find-oxfmt-config [bufnr]
  (let [fname (vim.api.nvim_buf_get_name bufnr)]
    (if (not= fname "")
        (let [root-markers (lspconfig-util.insert_package_json [:.oxfmtrc.json
                                                                 :oxfmt.config.ts
                                                                 :oxfmt.config.js
                                                                 :oxfmt.config.mjs
                                                                 :oxfmt.config.cjs]
                                                                :oxfmt
                                                                fname)]
          (. (vim.fs.find root-markers
                          {:path fname
                           :upward true
                           :type :file
                           :limit 1})
             1))
        nil)))

(fn default-root-dir [bufnr on-dir]
  (let [project-root (vim.fs.root bufnr [".git"])]
    (on-dir (if project-root project-root (vim.fn.getcwd)))))

(fn oxfmt-root-dir [bufnr on-dir]
  (let [config-file (find-oxfmt-config bufnr)]
    (if config-file
        (on-dir (vim.fs.dirname config-file)))))

(fn prettier-root-dir [bufnr on-dir]
  (if (find-oxfmt-config bufnr)
      nil
      (default-root-dir bufnr on-dir)))

(local base-languages
  {:fennel [fnlfmt]
   :go [gofmt]
   :lua [luacheck]
   ; TODO: how to replicate the "injected" thing from conform?
   :terraform [terraform_fmt]
   :sh [shellcheck]})

(local prettier-languages
  {:javascript [prettier]
   :javascriptreact [prettier]
   :json [prettier]
   :jsonc [prettier]
   :markdown [prettier]
   :typescript [prettier]
   :typescriptreact [prettier]})

(local oxfmt-languages
  {:javascript [oxfmt]
   :javascriptreact [oxfmt]
   :json [oxfmt]
   :jsonc [oxfmt]
   :markdown [oxfmt]
   :typescript [oxfmt]
   :typescriptreact [oxfmt]})

(fn _setup []
  (local setup-args (lspconfig-setup.make-setup-args))
  (vim.lsp.config :efm
                  (vim.tbl_deep_extend :force setup-args
                                        {:cmd [:efm-langserver]
                                         :root_dir default-root-dir
                                         :filetypes (vim.tbl_keys base-languages)
                                         :settings {:rootMarkers [:.git/]
                                                    :languages base-languages
                                                    :logLevel 10}
                                         :init_options {:documentFormatting true
                                                        :documentRangeFormatting true}}))
  (vim.lsp.config :efm_prettier
                  (vim.tbl_deep_extend :force setup-args
                                        {:cmd [:efm-langserver]
                                         :root_dir prettier-root-dir
                                         :filetypes (vim.tbl_keys prettier-languages)
                                         :settings {:rootMarkers [:.git/]
                                                    :languages prettier-languages
                                                    :logLevel 10}
                                         :init_options {:documentFormatting true
                                                        :documentRangeFormatting true}}))
  (vim.lsp.config :efm_oxfmt
                  (vim.tbl_deep_extend :force setup-args
                                        {:cmd [:efm-langserver]
                                         :root_dir oxfmt-root-dir
                                         :filetypes (vim.tbl_keys oxfmt-languages)
                                         :settings {:rootMarkers [:.git/]
                                                    :languages oxfmt-languages
                                                    :logLevel 10}
                                         :init_options {:documentFormatting true
                                                        :documentRangeFormatting true}}))
  (vim.lsp.enable [:efm :efm_prettier :efm_oxfmt]))

(var is-loaded false)

(fn setup []
  (if (not is-loaded)
      (do
        (_setup)
        (make-format-augroup)
        (create-formatting-autocmd)
        (set is-loaded true))))

{: setup}
