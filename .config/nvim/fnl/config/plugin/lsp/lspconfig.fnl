(module config.plugin.lspconfig
        {autoload {nvim aniseed.nvim
                   lsp lspconfig
                   util config.plugin.lsp.util
                   t telescope.builtin
                   cmplsp cmp_nvim_lsp}})

; symbols to show for lsp diagnostics
(defn define-signs [prefix]
      (let [error (.. prefix :SignError)
            warn (.. prefix :SignWarn)
            info (.. prefix :SignInfo)
            hint (.. prefix :SignHint)]
        (vim.fn.sign_define error {:text :x :texthl error})
        (vim.fn.sign_define warn {:text "!" :texthl warn})
        (vim.fn.sign_define info {:text :i :texthl info})
        (vim.fn.sign_define hint {:text "?" :texthl hint})))

; server features
(defn make-setup-args []
      "return a map of on_attach, handlers, capailities to pass to lsp.x.setup calls"
      {:handlers {:textDocument/publishDiagnostics (vim.lsp.with vim.lsp.diagnostic.on_publish_diagnostics
                                                                 {:severity_sort true
                                                                  :update_in_insert false
                                                                  :underline true
                                                                  :virtual_text false})
                  :textDocument/hover (vim.lsp.with vim.lsp.handlers.hover
                                                    {:border :single})
                  :textDocument/signatureHelp (vim.lsp.with vim.lsp.handlers.signature_help
                                                            {:border :single})}
       :capailities (cmplsp.update_capabilities (vim.lsp.protocol.make_client_capabilities))
       :on_attach (fn [client bufnr]
                    (do
                      (vim.keymap.set :n :gd vim.lsp.buf.definition
                                      {:desc "Go to definition" :buffer bufnr})
                      (vim.keymap.set :n :K vim.lsp.buf.hover {:buffer bufnr})
                      (vim.keymap.set :n :<leader>gd vim.lsp.buf.declaration
                                      {:buffer bufnr})
                      (vim.keymap.set :n :<leader>gt
                                      vim.lsp.buf.type_definition
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
                      (vim.keymap.set :v :<leader>la
                                      vim.lsp.buf.range_code_action
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

(defn- _setup []
       (let [setup-args (make-setup-args)]
         (lsp.clojure_lsp.setup setup-args)
         (lsp.tsserver.setup setup-args)
         (lsp.sumneko_lua.setup setup-args)
         (if (= (nvim.fn.has :nvim-0.6) 1)
             (define-signs :Diagnostic)
             (define-signs :LspDiagnostics)) ; top-level keybinding for formatting so we can format stuff that only has null-ls and not other LSP
         ; TODO: this manual keybinding works but the autoformat stuff doesn't appear to work
         (vim.keymap.set :n :<leader>lf #(util.lsp-format 0))
         (vim.keymap.set :v :<leader>lf #(util.lsp-format 0))))

(var is-loaded false)
(defn setup [] (if (not is-loaded)
                   (do
                     (_setup)
                     (set is-loaded true))))
