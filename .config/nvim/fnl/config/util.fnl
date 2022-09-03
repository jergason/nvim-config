(module config.util
  {autoload {nvim aniseed.nvim}})

(defn nnoremap [from to]
  (nvim.set_keymap :n (.. "<leader>" from) (.. ":" to "<cr>") {:noremap true}))

(defn vnoremap [from to]
  nvim.set_keymap :v (.. "<leader>" from) (.. ":" to "<cr>") {:noremap true})
