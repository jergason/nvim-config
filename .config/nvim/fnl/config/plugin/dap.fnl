(module config.plugin.dap
        {autoload {nvim aniseed.nvim
                   dap dap
                   dapui dapui
                   dapjs dap-vscode-js
                   utils dap.utils
                   vscode dap.ext.vscode}})

(local languages [:javascript :typescript :javascriptreact :typescriptreact])

(dapjs.setup {:adapters [:pwa-chrome :pwa-node]})

; set up config
(each [_ language (ipairs languages)]
  (tset dap.configurations language
        [; debug individual files
         {:type :pwa-node
          :request :launch
          :name "Launch file"
          :program "${file}"
          :cwd (vim.fn.getcwd)
          :sourceMaps true}
         ; debug running node processes
         {:type :pwa-node
          :request :attach
          :name :Attach
          :processId utils.pick_process
          :cdw (vim.fn.getcwd)
          :sourceMaps true}
         {:type :pwa-chrome
          :request :launch
          :name "Launch and Debug Chrome"
          :url "http://localhost:8000"
          :webRoot (vim.fn.getcwd)
          :sourceMaps true
          :protocol :inspector}]))

(local launchjson :.vscode/launch.json)
(vim.keymap.set :n :<leader>da
                #(when (vim.fn.filereadable launchjson) ; TODO: this doesn't work, not sure why
                   (vscode.load_launchjs launchjson)
                   (dap.continue))
                {:desc "Start debugging with vscode arguments"})

; set mappings for dap
(vim.keymap.set :n :<leader>dc #(dap.continue))
(vim.keymap.set :n :<leader>dB
                #(dap.set_breakpoint (vim.fn.input "Breakpoint condition: "))
                {:desc "Set conditional breakpoint"})

(vim.keymap.set :n :<leader>db #(dap.toggle_breakpoint))
(vim.keymap.set :n :<leader>dC #(dap.run_to_cursor))
(vim.keymap.set :n :<leader>di #(dap.step_into) {:desc "Step into"})
(vim.keymap.set :n :<leader>dj #(dap.down))
(vim.keymap.set :n :<leader>dk #(dap.up))
(vim.keymap.set :n :<leader>dO #(dap.step_over))
(vim.keymap.set :n :<leader>do #(dap.step_out) {:desc "Step out"})
(vim.keymap.set :n :<leader>dr #(dap.repl.toggle) {:desc "Toggle dap-repl"})

(dapui.setup)
(vim.keymap.set :n :<leader>du #(dapui.toggle) {:desc "Toggle dap-ui"})
(vim.keymap.set :n :<leader>de #(dapui.eval)
                {:desc "Evaluate an expression in dap-ui"})

; override with .vscode/launch.json file

