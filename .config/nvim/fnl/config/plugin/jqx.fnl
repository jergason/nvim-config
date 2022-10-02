(module config.plugin.jqx
  {autoload {jqx nvim-jqx.config}})

(set jqx.sort false)

(vim.keymap.set :n :<leader>jq :<cmd>JqxList<cr> {:desc "format json w/ jq"})
