(module config.plugin.lsp.util {autoload {nvim aniseed.nvim}})

(defn lsp-format [bufnr]
      (vim.lsp.buf.format {: bufnr
                           ; only use null-ls to format
                           :filter (fn [client]
                                     (= client.name :null-ls))}))

(defn create-formatting-autocmd [group buffer]
      (vim.api.nvim_clear_autocmds {: group : buffer})
      (vim.api.nvim_create_autocmd :BufWritePre
                                   {: group
                                    : buffer
                                    :callback #(lsp-format bufnr)}))
