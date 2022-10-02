(module config.plugin.lsp.null-ls
        {autoload {null-ls null-ls util config.plugin.lsp.util}})

(def- augroup-name :LspFormatting)

(defn- make-format-augroup [] (vim.api.nvim_create_augroup augroup-name {}))

(defn- _setup []
       (let [augroup (make-format-augroup)]
         (null-ls.setup {:sources [;formatting
                                   null-ls.builtins.formatting.prettier
                                   null-ls.builtins.formatting.fnlfmt
                                   null-ls.builtins.formatting.cljstyle
                                   ;diagnostics
                                   null-ls.builtins.diagnostics.eslint
                                   null-ls.builtins.diagnostics.luacheck
                                   null-ls.builtins.diagnostics.shellcheck
                                   ;code actions
                                   null-ls.builtins.code_actions.shellcheck
                                   null-ls.builtins.code_actions.eslint]
                         :on_attach (fn [client bufnr]
                                      (util.create-formatting-autocmd augroup
                                                                      bufnr))})))

(var is-setup false)
(defn setup [] (if (not is-setup)
                   (do
                     (_setup)
                     (set is-setup true))))
