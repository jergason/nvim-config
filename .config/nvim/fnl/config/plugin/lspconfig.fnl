(module config.plugin.lspconfig
  {autoload {nvim aniseed.nvim
             lsp lspconfig
             cmplsp cmp_nvim_lsp}})

;symbols to show for lsp diagnostics
(defn define-signs
  [prefix]
  (let [error (.. prefix "SignError")
        warn  (.. prefix "SignWarn")
        info  (.. prefix "SignInfo")
        hint  (.. prefix "SignHint")]
  (vim.fn.sign_define error {:text "x" :texthl error})
  (vim.fn.sign_define warn  {:text "!" :texthl warn})
  (vim.fn.sign_define info  {:text "i" :texthl info})
  (vim.fn.sign_define hint  {:text "?" :texthl hint})))

(if (= (nvim.fn.has "nvim-0.6") 1)
  (define-signs "Diagnostic")
  (define-signs "LspDiagnostics"))

;server features
(let [handlers {"textDocument/publishDiagnostics"
                (vim.lsp.with
                  vim.lsp.diagnostic.on_publish_diagnostics
                  {:severity_sort true
                   :update_in_insert false
                   :underline true
                   :virtual_text false})
                "textDocument/hover"
                (vim.lsp.with
                  vim.lsp.handlers.hover
                  {:border "single"})
                "textDocument/signatureHelp"
                (vim.lsp.with
                  vim.lsp.handlers.signature_help
                  {:border "single"})}
      capabilities (cmplsp.update_capabilities (vim.lsp.protocol.make_client_capabilities))
      on_attach (fn [client bufnr]
                  (do
                    (nvim.buf_set_keymap bufnr :n :gd "<Cmd>lua vim.lsp.buf.definition()<CR>" {:noremap true})
                    (nvim.buf_set_keymap bufnr :n :K "<Cmd>lua vim.lsp.buf.hover()<CR>" {:noremap true})
                    (nvim.buf_set_keymap bufnr :n :<leader>gd "<Cmd>lua vim.lsp.buf.declaration()<CR>" {:noremap true})
                    ;(nvim.buf_set_keymap bufnr :n :<leader>ds "<Cmd>lua vim.lsp.buf.document_symbol()<CR>" {:noremap true})
                    (nvim.buf_set_keymap bufnr :n :<leader>gt "<cmd>lua vim.lsp.buf.type_definition()<CR>" {:noremap true})
                    (nvim.buf_set_keymap bufnr :n :<leader>gh "<cmd>lua vim.lsp.buf.signature_help()<CR>" {:noremap true})
                    ;(nvim.buf_set_keymap bufnr :n :<leader>ic "<cmd>lua vim.lsp.buf.incoming_calls()<CR>" {:noremap true})
                    ;(nvim.buf_set_keymap bufnr :n :<leader>oc "<cmd>lua vim.lsp.buf.outgoing_calls()<CR>" {:noremap true})

                    (nvim.buf_set_keymap bufnr :n :<leader>rn "<cmd>lua vim.lsp.buf.rename()<CR>" {:noremap true})
                    (nvim.buf_set_keymap bufnr :n :<leader>le "<cmd>lua vim.diagnostic.open_float()<CR>" {:noremap true})
                    (nvim.buf_set_keymap bufnr :n :<leader>lq "<cmd>lua vim.diagnostic.setloclist()<CR>" {:noremap true})
                    (nvim.buf_set_keymap bufnr :n :<leader>lf "<cmd>lua vim.lsp.buf.formatting()<CR>" {:noremap true})
                    (nvim.buf_set_keymap bufnr :n :<leader>dj "<cmd>lua vim.diagnostic.goto_next()<CR>" {:noremap true})
                    (nvim.buf_set_keymap bufnr :n :<leader>dk "<cmd>lua vim.diagnostic.goto_prev()<CR>" {:noremap true})
                    (nvim.buf_set_keymap bufnr :n :<leader>ca "<cmd>lua vim.lsp.buf.code_action()<CR>" {:noremap true})
                    (nvim.buf_set_keymap bufnr :v :<leader>la "<cmd>lua vim.lsp.buf.range_code_action()<CR> " {:noremap true})
                    ;telescope
                    (nvim.buf_set_keymap bufnr :n :<leader>lw ":lua require('telescope.builtin').lsp_workspace_diagnostics()<cr>" {:noremap true})
                    (nvim.buf_set_keymap bufnr :n :<leader>lr ":lua require('telescope.builtin').lsp_references()<cr>" {:noremap true})
                    (nvim.buf_set_keymap bufnr :n :<leader>ds ":lua require('telescope.builtin').lsp_document_symbols()<cr>" {:noremap true})
                    (nvim.buf_set_keymap bufnr :n :<leader>ic ":lua require('telescope.builtin').lsp_incoming_calls()<cr>" {:noremap true})
                    (nvim.buf_set_keymap bufnr :n :<leader>oc ":lua require('telescope.builtin').lsp_outgoing_calls()<cr>" {:noremap true})
                    (nvim.buf_set_keymap bufnr :n :<leader>li ":lua require('telescope.builtin').lsp_implementations()<cr>" {:noremap true})))]

  ;; Clojure
  (lsp.clojure_lsp.setup {:on_attach on_attach
                          :handlers handlers
                          :capabilities capabilities})
  (lsp.tsserver.setup {:on_attach on_attach
                          :handlers handlers
                          :capabilities capabilities})
  (lsp.sumneko_lua.setup {:on_attach on_attach
                          :handlers handlers
                          :capabilities capabilities})
  )
