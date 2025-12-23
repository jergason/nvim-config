(fn nnoremap [from to]
  (vim.api.nvim_set_keymap :n (.. :<leader> from) (.. :<cmd> to :<cr>) {:noremap true}))

(fn vnoremap [from to]
  (vim.api.nvim_set_keymap :v (.. :<leader> from) (.. :<cmd> to :<cr>) {:noremap true}))

{: nnoremap : vnoremap}
