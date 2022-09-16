;quickfix bindings
; TODO: how to make this buffer local?
(vim.keymap.set :n :<CR> :<cmd>.cc<cr> {:desc "Jump to selected quickfix item." :buffer 0})
