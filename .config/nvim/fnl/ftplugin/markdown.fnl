(set vim.opt_local.linebreak true)
(set vim.opt_local.breakindent true)

(local markdown-wrap (require :config.markdown-wrap))

(vim.api.nvim_buf_create_user_command 0 :MarkdownWrap markdown-wrap.wrap
                                      {:desc "Wrap markdown prose paragraph"})

(vim.api.nvim_buf_create_user_command 0 :MarkdownUnwrap markdown-wrap.unwrap
                                      {:desc "Unwrap markdown prose paragraph"})

(vim.api.nvim_buf_create_user_command 0 :MarkdownToggleWrap
                                      markdown-wrap.toggle
                                      {:desc "Toggle markdown prose paragraph wrapping"})

(vim.keymap.set :n :<leader>mw markdown-wrap.toggle
                {:buffer 0 :desc "Toggle markdown prose wrapping"})

(vim.keymap.set :n :<leader>mW markdown-wrap.unwrap
                {:buffer 0 :desc "Unwrap markdown prose"})
