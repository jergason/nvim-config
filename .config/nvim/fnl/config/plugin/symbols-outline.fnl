(local sl (require :symbols-outline))
(local u (require :config.util))

(sl.setup)
(u.nnoremap :sol :SymbolsOutline)

; don't bind to help file types since they already implement gO
(fn bind-symbols-outline []
  (if (not (= vim.o.ft :help))
      (vim.api.nvim_buf_set_keymap 0 :n :gO :<cmd>SymbolsOutline<cr> {})))

;use gO like in help to outline stuff that isn't help text
; TODO: Error detected while processing BufEnter Autocommands for "*":
; Error executing lua callback: Expected 5 arguments
; stack traceback:
;         [C]: at 0x0100351200
; Error detected while processing function <SNR>70_NetrwBrowseChgDir[197]..BufEnter Autocommands for "*":
; Error executing lua callback: Expected 5 arguments
; stack traceback:
;         [C]: at 0x0100351200
;(vim.api.nvim_create_autocmd :BufEnter {:pattern "*" :callback #(bind-symbols-outline)})
