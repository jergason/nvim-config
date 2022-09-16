(module config.plugin.symbols-outline
  {autoload {sl symbols-outline
             u config.util
             nvim aniseed.nvim}})

(sl.setup)
(u.nnoremap :sl :SymbolsOutline)

; don't bind to help file types since they already implement gO
(defn bind-symbols-outline []
  (if  (not (= nvim.o.ft "help") )
    (nvim.buf_set_keymap 0 :n :gO :<cmd>SymbolsOutline<cr>)))

;use gO like in help to outline stuff that isn't help text
; TODO: Error detected while processing BufEnter Autocommands for "*":                                                                                                                     
; Error executing lua callback: Expected 5 arguments                                                                                                                                 
; stack traceback:                                                                                                                                                                   
;         [C]: at 0x0100351200                                                                                                                                                       
; Error detected while processing function <SNR>70_NetrwBrowseChgDir[197]..BufEnter Autocommands for "*":                                                                            
; Error executing lua callback: Expected 5 arguments                                                                                                                                 
; stack traceback:                                                                                                                                                                   
;         [C]: at 0x0100351200 
;(nvim.create_autocmd :BufEnter {:pattern "*" :callback #(bind-symbols-outline)})

