(module config.plugin.cmp {autoload {nvim aniseed.nvim cmp cmp}})

(def- cmp-src-menu-items
  {:buffer "[Buf]" :conjure "[Conj]" :nvim_lsp "[LSP]"})

(def- cmp-srcs
  [{:name :nvim_lsp} {:name :conjure} {:name :buffer}])

; stolen from github.com/LunarVim/Neovim-from-scratch
(def- kind-icons
  {:Text ""
   :Method :m
   :Function ""
   :Constructor ""
   :Field ""
   :Variable ""
   :Class ""
   :Interface ""
   :Module ""
   :Property ""
   :Unit ""
   :Value ""
   :Enum ""
   :Keyword ""
   :Snippet ""
   :Color ""
   :File ""
   :Reference ""
   :Folder ""
   :EnumMember ""
   :Constant ""
   :Struct ""
   :Event ""
   :Operator ""
   :TypeParameter ""})

;; Setup cmp with desired settings

(fn has-words-before []
  (let [(line col) (unpack (vim.api.nvim_win_get_cursor 0))]
    (and (not= col 0) (= (: (: (. (vim.api.nvim_buf_get_lines 0 (- line 1) line
                                                              true)
                                  1) :sub col
                               col) :match "%s") nil))))

(cmp.setup {:formatting {:format (fn [entry item]
                                   (set item.menu
                                        (or (. cmp-src-menu-items
                                               entry.source.name)
                                            ""))
                                   (set item.kind
                                        (or (. kind-icons item.kind) ""))
                                   item)
                         :fields [:kind :abbr :menu]}
            :window {:completion (cmp.config.window.bordered)
                     :documentation (cmp.config.window.bordered)}
            :mapping {:<C-p> (cmp.mapping.select_prev_item)
                      :<C-n> (cmp.mapping.select_next_item)
                      :<C-b> (cmp.mapping.scroll_docs (- 4))
                      :<C-f> (cmp.mapping.scroll_docs 4)
                      :<C-Space> (cmp.mapping.complete)
                      :<C-e> (cmp.mapping.close)
                      :<CR> (cmp.mapping.confirm {:behavior cmp.ConfirmBehavior.Insert
                                                  :select true})
                      :<Tab> (cmp.mapping (fn [fallback]
                                            (if (cmp.visible)
                                                (cmp.select_next_item)
                                                (has-words-before)
                                                (cmp.complete)
                                                :else
                                                (fallback)))
                                          {1 :i 2 :s})
                      :<S-Tab> (cmp.mapping (fn [fallback]
                                              (if (cmp.visible)
                                                  (cmp.select_prev_item)
                                                  :else
                                                  (fallback)))
                                            {1 :i 2 :s})}
            :sources cmp-srcs})
