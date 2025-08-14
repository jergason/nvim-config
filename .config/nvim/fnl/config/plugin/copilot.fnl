(module config.plugin.copilot)

; Argument to Accept is the fallback if there is no suggestion
; Here we provide an empty string so that nothing is inserted
(vim.keymap.set :i :<C-J> "copilot#Accept(\"\")"
                {:remap false
                 :silent true
                 :script true
                 :replace_keycodes false
                 :expr true
                 :desc "Accept copilot suggestions"})

(set vim.g.copilot_no_tab_map true)

(vim.keymap.set :i :<C-N> "<Plug>(copilot-dismiss)"
                {:desc "Dismiss copilot suggestions"})

(vim.keymap.set :i "<C-'>" "<Plug>(copilot-next)")

(vim.keymap.set :i "<C-:>" "<Plug>(copilot-previous)")
