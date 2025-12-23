(local eslint (require :efmls-configs.linters.eslint))
(local eslint-fmt (require :efmls-configs.formatters.eslint))
(local luacheck (require :efmls-configs.linters.luacheck))
(local shellcheck (require :efmls-configs.linters.shellcheck))
(local fnlfmt (require :efmls-configs.formatters.fnlfmt))
(local gofmt (require :efmls-configs.formatters.gofmt))
(local prettier (require :efmls-configs.formatters.prettier))
(local terraform_fmt (require :efmls-configs.formatters.terraform_fmt))
(local lspconfig-setup (require :config.plugin.lsp.lspconfig))

; efm is used for formatting on save
; sometimes it doesn't work and i don't know why ;_;
; https://github.com/creativenull/efmls-configs-nvim/tree/main?tab=readme-ov-file#format-on-save
(local formatting-group-name :LspFormatting)

(fn make-format-augroup []
  (vim.api.nvim_create_augroup formatting-group-name {}))

(fn lsp-format []
  (vim.lsp.buf.format {:filter (fn [client] (= client.name :efm))}))

(fn create-formatting-autocmd []
  (vim.api.nvim_clear_autocmds {:group formatting-group-name})
  (vim.api.nvim_create_autocmd :BufWritePre
                               {:group formatting-group-name
                                :callback #(lsp-format)}))

(local languages
  {:fennel [fnlfmt]
   :go [gofmt]
   :javascript [prettier eslint]
   :javascriptreact [prettier eslint]
   :json [prettier]
   :jsonc [prettier]
   :lua [luacheck]
   ; TODO: how to replicate the "injected" thing from conform?
   :markdown [prettier]
   :terraform [terraform_fmt]
   :typescript [prettier eslint]
   :typescriptreact [prettier eslint]
   :sh [shellcheck]})

(fn _setup []
  (local setup-args (lspconfig-setup.make-setup-args))
  (vim.lsp.config :efm
                  (vim.tbl_deep_extend :force setup-args
                                       {:filetypes (vim.tbl_keys languages)
                                        :settings {:rootMarkers [:.git/] : languages :logLevel 10}
                                        :init_options {:documentFormatting true
                                                       :documentRangeFormatting true}}))
  (vim.lsp.enable :efm))

(var is-loaded false)

(fn setup []
  (if (not is-loaded)
      (do
        (_setup)
        (make-format-augroup)
        (create-formatting-autocmd)
        (set is-loaded true))))

{: setup}
