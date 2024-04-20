(module config.plugin.open-browser {autoload {nvim aniseed.nvim}})

; bindings for open-browser
(nvim.set_keymap :n :gx "<Plug>(openbrowser-smart-search)" {})
(nvim.set_keymap :v :gx "<Plug>(openbrowser-smart-search)" {})

