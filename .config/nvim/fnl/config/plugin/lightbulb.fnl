(module config.plugin.lightbulb
  {autoload {lightbulb nvim-lightbulb}})

(lightbulb.setup {:autocmd {:enabled true}})
