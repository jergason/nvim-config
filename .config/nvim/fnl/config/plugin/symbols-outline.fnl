(module config.plugin.symbols-outline
  {autoload {sl symbols-outline
             u config.util
             nvim aniseed.nvim}})

(sl.setup)
(u.nnoremap :sl :SymbolsOutline)

; don't bind to help file types since they already implement gO
(defn bind-symbols-outline []
  (if  (not (= nvim.o.ft "help") )
    (nvim.buf_set_keymap 0 :n :gO :<cmd>SymbolsOutline)))

; TODO: this seems to not work, because it thinks it isn't the name of a lua function?
;use gO like in help to outline stuff that isn't help text
;(nvim.create_autocmd :BufEnter {:pattern "*" :callback bind-symbols-outline})

