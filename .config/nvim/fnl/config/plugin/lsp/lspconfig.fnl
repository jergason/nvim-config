(module config.plugin.lsp.lspconfig
        {autoload {nvim aniseed.nvim
                   core aniseed.core
                   util config.plugin.lsp.util
                   t telescope.builtin
                   tstools typescript-tools
                   cmplsp cmp_nvim_lsp}})

; symbols to show for lsp diagnostics
; (defn- define-signs
;   []
;   (let [prefix :Diagnostic
;         error (.. prefix :SignError)
;         warn (.. prefix :SignWarn)
;         info (.. prefix :SignInfo)
;         hint (.. prefix :SignHint)]
;     (vim.diagnostics.config {:signs {} })
;     (vim.fn.sign_define error {:text :x :texthl error})
;     (vim.fn.sign_define warn {:text "!" :texthl warn})
;     (vim.fn.sign_define info {:text :i :texthl info})
;     (vim.fn.sign_define hint {:text "?" :texthl hint})))

; server features
(defn- make-setup-args
  []
  "return a map of on_attach, handlers, capabilities to pass to `vim.lsp.config` calls"
  {:handlers {:textDocument/publishDiagnostics (vim.lsp.with vim.lsp.diagnostic.on_publish_diagnostics
                                                 {:severity_sort true
                                                  :virtual_text false})
              :textDocument/hover (vim.lsp.with vim.lsp.handlers.hover
                                    {:border :single})
              :textDocument/signatureHelp (vim.lsp.with vim.lsp.handlers.signature_help
                                            {:border :single})}
   :capabilities (cmplsp.default_capabilities (vim.lsp.protocol.make_client_capabilities))
   :on_attach (fn [client bufnr]
                (do
                  (vim.keymap.set :n :gd vim.lsp.buf.definition
                                  {:desc "Go to definition" :buffer bufnr})
                  (vim.keymap.set :n :<leader>gd vim.lsp.buf.declaration
                                  {:buffer bufnr})
                  (vim.keymap.set :n :<leader>gh vim.lsp.buf.signature_help
                                  {:buffer bufnr})
                  (vim.keymap.set :n :<leader>rn vim.lsp.buf.rename
                                  {:buffer bufnr})
                  (vim.keymap.set :n :<leader>le vim.diagnostic.open_float
                                  {:buffer bufnr})
                  (vim.keymap.set :n :<leader>lq vim.diagnostic.setqflist
                                  {:buffer bufnr})
                  (vim.keymap.set :n :<leader>lf vim.lsp.buf.format
                                  {:buffer bufnr})
                  (vim.keymap.set :n :<leader>dj vim.diagnostic.goto_next
                                  {:buffer bufnr})
                  (vim.keymap.set :n :<leader>dk vim.diagnostic.goto_prev
                                  {:buffer bufnr})
                  (vim.keymap.set :n :<leader>ca vim.lsp.buf.code_action
                                  {:buffer bufnr})
                  ;telescope
                  (vim.keymap.set :n :<leader>ld
                                  ":lua require('telescope.builtin').diagnostics()<cr>"
                                  {:buffer bufnr})
                  (vim.keymap.set :n :<leader>lr
                                  ":lua require('telescope.builtin').lsp_references()<cr>"
                                  {:buffer bufnr})
                  (vim.keymap.set :n :<leader>ds
                                  "<cmd>lua require('telescope.builtin').lsp_document_symbols()<cr>"
                                  {:buffer bufnr})
                  (vim.keymap.set :n :<leader>ic
                                  "<cmd>lua require('telescope.builtin').lsp_incoming_calls()<cr>"
                                  {:buffer bufnr})
                  (vim.keymap.set :n :<leader>oc
                                  "<cmd> lua require('telescope.builtin').lsp_outgoing_calls()<cr>"
                                  {:buffer bufnr})
                  (vim.keymap.set :n :<leader>li
                                  "<cmd> lua require ('telescope.builtin').lsp_implementations()<cr>"
                                  {:buffer bufnr})))})

(defn- _setup
  []
  (let [setup-args (make-setup-args)]
    (vim.lsp.config "*" setup-args) ; (lsp.bashls.setup setup-args) ; (lsp.clangd.setup setup-args) ; (lsp.gopls.setup setup-args) ; (lsp.graphql.setup setup-args)
    (vim.lsp.config :lua_ls
                    (core.merge setup-args
                                {:runtime {:version :LuaJIT}
                                 :diagnostics {:globals [:vim]}
                                 :telemetry {:enable false}})) ; (lsp.ocamllsp.setup setup-args) ; (lsp.pyright.setup setup-args) ; (lsp.rust_analyzer.setup setup-args) ; (lsp.terraformls.setup setup-args)
    (vim.lsp.config :vtsls
                    (core.merge setup-args
                                {:settings {:typescript {:tsserver {:maxTsServerMemory 8192
                                                                    :nodePath "node --max-old-space-size=8192"}}}}))
    (vim.lsp.enable [:bashls
                     :clangd
                     :gopls
                     :lua_ls
                     :terraformls
                     :vtsls
                     :yamlls]) ; hrrm, old commented-out stuff ; (tstools.setup (core.merge setup-args ;                            ; see if this helps with running out of memory on work codebase
    ;                            {:settings {:tsserver_max_memory 8192}})) ; (lsp.yamlls.setup setup-args) ; (define-signs) ; top-level keybinding for formatting so we can format stuff that only has null-ls and not other LSP
    ; TODO: this manual keybinding works but the autoformat stuff doesn't appear to work
    (vim.keymap.set :n :<leader>lf #(util.lsp-format 0))
    (vim.keymap.set :v :<leader>lf #(util.lsp-format 0))))

(var is-loaded false)
(defn setup
  []
  (if (not is-loaded)
      (do
        (_setup)
        (set is-loaded true))))
