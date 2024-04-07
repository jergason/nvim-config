(module ftplugin.fennel {autoload {nvim aniseed.nvim}})

; TODO: define a command that saves the fnl file and then evaluates it with Conjure
(nvim.buf_set_keymap 0 :n :<Leader><Leader>x ":w<CR>:ConjureEval<CR>"
                     {:noremap true :silent true})

