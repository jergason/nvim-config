(module config.util
  {autoload {nvim aniseed.nvim
             core aniseed.core}})

(defn nnoremap [from to]
  (nvim.set_keymap :n (.. "<leader>" from) (.. "<cmd>" to "<cr>") {:noremap true}))

(defn vnoremap [from to]
  nvim.set_keymap :v (.. "<leader>" from) (.. "<cmd>" to "<cr>") {:noremap true})

(defn includes [collection element]
  "return true if collection includes element, nil otherwise"
  (core.some #(= $1 element)))
