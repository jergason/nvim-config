(module config.plugin.markdown-preview {autoload {nvim aniseed.nvim}})

(vim.keymap.set :n :<leader>md :<cmd>MarkdownPreviewToggle<cr>)

