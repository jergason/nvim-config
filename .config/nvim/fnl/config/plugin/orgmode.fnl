(module config.plugin.orgmode
  {autoload {nvim aniseed.nvim
             orgmode orgmode }})

; Do i need more than this?
(orgmode.setup_ts_grammar)
(orgmode.setup)
