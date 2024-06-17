(module config.plugin.lsp.efm
        {require {eslint efmls-configs.linters.eslint
                  jq efmls-configs.linters.jq
                  luacheck efmls-configs.linters.luacheck
                  shellcheck efmls-configs.linters.shellcheck
                  fnlfmt efmls-configs.formatters.fnlfmt
                  gofmt efmls-configs.formatters.gofmt
                  prettier efmls-configs.formatters.prettier
                  terraform_fmt efmls-configs.formatters.terraform_fmt}
         autoload {core aniseed.core lsp lspconfig}})

; https://github.com/creativenull/efmls-configs-nvim/tree/main?tab=readme-ov-file#format-on-save
(def- formatting-group-name :LspFormatting)
(defn- make-format-augroup []
  (vim.api.nvim_create_augroup formatting-group-name {}))

(defn- lsp-format
  []
  (vim.lsp.buf.format {:filter (fn [client] (= client.name :efm))}))

(defn- create-formatting-autocmd
  []
  (vim.api.nvim_clear_autocmds {:group formatting-group-name})
  (vim.api.nvim_create_autocmd :BufWritePre
                               {:group formatting-group-name
                                :callback #(lsp-format)}))

(def- languages
  {:fennel [fnlfmt]
   :go [gofmt]
   :javascript [prettier eslint]
   :javascriptreact [prettier eslint]
   :json [prettier jq]
   :lua [luacheck]
   ; TODO: how to replicate the "injected" thing from conform?
   :markdown [prettier]
   :terraform [terraform_fmt]
   :typescript [prettier eslint]
   :typescriptreact [prettier eslint]
   :sh [shellcheck]})

(defn- _setup
  []
  (lsp.efm.setup {:filetypes (core.keys languages)
                  :settings {:rootMarkers [:.git/] : languages :logLevel 10}
                  :init_options {:documentFormatting true
                                 :documentRangeFormatting true}}))

(var is-loaded false)
(defn setup
  []
  (if (not is-loaded)
      (do
        (_setup)
        (make-format-augroup)
        (create-formatting-autocmd)
        (set is-loaded true))))

