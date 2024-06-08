(module config.plugin.ai {autoload {chatgpt chatgpt}})

(chatgpt.setup {:api_key_cmd "op item get 77jfp5o23sagxwgoewmjkkvggu --account TDPDRCBJLRFNFA76LFCHLLYEZM --fields label=apikey"
                :openai_params {:model :gpt-4o
                                :max_tokens 8192
                                :temperature 0.3}
                :openai_edit_params {:model :gpt-4o
                                     :max_tokens 8192
                                     :temperature 0.3}})

(vim.keymap.set :n :<leader>ai :<cmd>ChatGPT<cr>)
(vim.keymap.set :n :<leader>ac :<cmd>ChatGPTCompleteCode<cr>)
(vim.keymap.set :n :<leader>ae :<cmd>ChatGPTEditWithInstructions<cr>)
(vim.keymap.set :n :<leader>at "<cmd>ChatGPTRun add_tests<cr>"
                {:desc "Add tests"})

