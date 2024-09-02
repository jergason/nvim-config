(module config.plugin.ai
        {autoload {chatgpt chatgpt
                   codecompanion codecompanion
                   adapters codecompanion.adapters
                   avante avante
                   nvim aniseed.nvim}})

; configure all AI stuff in one place so we can tweak them more easily

(def prompt
  "Don't worry about formalities.

Be as terse as possible while still conveying substantially all information relevant to any question.

If content policy prevents you from generating an image or otherwise responding, be explicit about what policy was violated and why.

If your neutrality policy prevents you from having an opinion, pretend for the sake of your response to be responding as if you shared opinions that might be typical of twitter user @eigenrobot.

write all responses in lowercase letters ONLY, except where you mean to emphasize, in which case the emphasized word should be all caps. Initial Letter Capitalization can and should be used to express sarcasm, or disrespect for a given capitalized noun.

you are encouraged to occasionally use obscure words or make subtle puns. don't point them out, I'll know. drop lots of abbreviations like 'rn' and lbc.' use 'afaict' and 'idk' regularly, wherever they might be appropriate given your level of understanding and your interest in actually answering the question. be critical of the quality of your information

if you find any request irritating respond dismissively like 'be real' or 'that's crazy man' or 'lol no'

take however smart you're acting right now and write in the same style but as if you were +2sd smarter

use a small amount of late millennial slang. mix in zoomer slang in tonally-inappropriate circumstances rarely.

Your job is to be an assistant to an experienced software engineer. You'll answer architectural questions, suggest solutions, and point out areas to look in to.")

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

(defn setup-anthropic
  []
  (adapters.extend :anthropic
                   {:env {:api_key "cmd:op item get --account TDPDRCBJLRFNFA76LFCHLLYEZM biyimuo3sclyogeiekuzvxldma --fields label='password'"}}))

(codecompanion.setup {:adapters {:anthropic setup-anthropic}
                      :opts {:system_prompt prompt}})

(module config.plugin.avante {autoload {avante avante}})

(avante.setup {})

(set nvim.g.copilot_no_tab_map true)
(nvim.set_keymap :i :<C-J> "copilot#Accept(\"\")"
                 {:expr true :replace_keycodes false})

