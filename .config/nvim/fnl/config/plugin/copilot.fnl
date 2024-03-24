(module config.plugin.copilot {autoload {nvim aniseed.nvim}})

(set nvim.g.copilot_no_tab_map true)
(nvim.set_keymap :i :<C-J> "copilot#Accept(\"\")"
                 {:expr true :replace_keycodes false})

