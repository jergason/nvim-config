(module config.plugin.lsp.null-ls
        {autoload {null-ls null-ls nvim aniseed.nvim}})

(def- augroup-name :LspFormatting)

(defn- make-format-augroup [] (vim.api.nvim_create_augroup augroup-name {}))

(defn- lsp-format
  [bufnr]
  (vim.lsp.buf.format {: bufnr
                       ; only use null-ls to format
                       :filter (fn [client]
                                 (= client.name :null-ls))}))

(defn- create-formatting-autocmd
  [group buffer]
  (vim.api.nvim_clear_autocmds {: group : buffer})
  (vim.api.nvim_create_autocmd :BufWritePre
                               {: group : buffer :callback #(lsp-format bufnr)}))

(defn- _setup
  []
  (let [augroup (make-format-augroup)]
    (null-ls.setup {:sources [;formatting
                              null-ls.builtins.formatting.prettier
                              null-ls.builtins.formatting.fnlfmt
                              null-ls.builtins.formatting.cljstyle
                              ;diagnostics
                              ;null-ls.builtins.diagnostics.eslint
                              ;null-ls.builtins.diagnostics.luacheck
                              ;null-ls.builtins.diagnostics.shellcheck
                              ;code actions
                              ;null-ls.builtins.code_actions.shellcheck
                              ;null-ls.builtins.code_actions.eslint
                              ]
                    ; enable debugging temporarily so we can see why eslint is failing
                    ;:debug true
                    ;; see if we can make null-ls just default to cwd
                    ;:root_dir (fn [filename] nil)
                    :on_attach (fn [client bufnr]
                                 (util.create-formatting-autocmd augroup bufnr))})))

(var is-setup false)
(defn setup
  []
  (if (not is-setup)
      (do
        (_setup)
        (set is-setup true))))
