(module config.plugin.trouble {autoload {trouble trouble}})

(trouble.setup)
(vim.keymap.set :n :<leader>xx "<cmd>Trouble diagnostics toggle<cr>"
                {:desc "toggle trouble"})

(vim.keymap.set :n :<leader>xX "<cmd>Trouble diagnostics toggle filter.buf=0<cr>"
                {:desc "buffer diagnostics"})

(vim.keymap.set :n :<leader>xL "<cmd>Trouble loclist toggle<cr>" {:desc "Location List (Trouble)"})

(vim.keymap.set :n :<leader>xQ "<cmd>Trouble qflist toggle<cr>" {:desc "Quickfix List (Trouble)"})

;vim.keymap.set("n", "<leader>xx", function() require("trouble").open() end)
;vim.keymap.set("n", "<leader>xw", function() require("trouble").open("workspace_diagnostics") end)
;vim.keymap.set("n", "<leader>xd", function() require("trouble").open("document_diagnostics") end)
;vim.keymap.set("n", "<leader>xq", function() require("trouble").open("quickfix") end)
;vim.keymap.set("n", "<leader>xl", function() require("trouble").open("loclist") end)
;vim.keymap.set("n", "gR", function() require("trouble").open("lsp_references") end) 

