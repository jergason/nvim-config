(module config.plugin.sterm
  {autoload {sterm sterm}})

(vim.keymap.set :n :<leader>te sterm.toggle {})
