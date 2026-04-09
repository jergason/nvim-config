(local util (require :config.util))

;generic mapping leaders configuration
(vim.api.nvim_set_keymap :n :<space> :<nop> {:noremap true})
(set vim.g.mapleader " ")
(set vim.g.maplocalleader " ")

(vim.api.nvim_create_autocmd :TermOpen
                             {:pattern "*"
                              :desc "Disable spellcheck in terminal"
                              :command "setlocal nospell"})

; enable :Cfilter for qfix list
(vim.cmd "packadd cfilter")

;hit enter to clear search highlights
(vim.api.nvim_set_keymap :n :<Enter> :<cmd>nohlsearch<cr> {})

; faster exiting terminal mode
(vim.api.nvim_set_keymap :t :<C-w> "<C-\\><C-n>"
                         {:noremap true :desc "Exit terminal insert mode"})

(vim.api.nvim_set_keymap :n :<leader>Y "<cmd>%y<CR>"
                         {:desc "Yank whole buffer" :noremap true})

;remove trailing whitespace
(util.nnoremap :ws "%s/\\s\\+$//e")
; I always hit this on the kinesis, just disable it
(vim.api.nvim_set_keymap :n :<F1> :<Nop> {})

(vim.keymap.set :n :<leader>yf #(vim.fn.setreg "+" (vim.fn.expand "%"))
                {:desc "Yank file path"})

; highlight yanked text
(vim.api.nvim_clear_autocmds {:event :TextYankPost})
(vim.api.nvim_create_autocmd :TextYankPost
                             {:pattern "*"
                              :desc "Highlight yanked text"
                              :callback #(vim.hl.on_yank {:timeout 350
                                                          :on_visual false
                                                          :higroup :IncSearch})})

(let [options {;settings needed for cmp autocompletion
               :completeopt "menu,menuone,noselect"
               ;case insensitive search
               :ignorecase true
               ;smart search case
               :smartcase true
               ;shared clipboard with os
               :clipboard :unnamedplus
               ;linebreak stuff
               ;wrap, but not in the middle of a word
               :wrap true
               :linebreak true
               ; wrappted text matches indent of above text
               :breakindent true
               :showbreak ">"
               :showmode false
               ;hybrid line numbers
               :nu true
               :rnu true
               ; set title of window to cwd
               :title true
               :titlestring (vim.fn.getcwd)
               ;show whitespace
               :list true
               ;add some lines below cursor
               :scrolloff 5
               ; new experimental option to make command at bottom of the window not show up unless needed
               :cmdheight 0
               ;beautify whitespace
               ; TODO for some reason this crashes fennel
               ;:listchars "tab:>-,trail:\\\\u22C5,extends:\\\\u2192,preceeds:\\\\u2190"
               ;transparent floating windows
               :winblend 10
               ; spell checking in comments. Depends on treesitter @spell capture. See https://www.reddit.com/r/neovim/comments/125whev/dumb_question_how_to_spell_check_only_comments/ for more info on how this works.
               ; :spell true
               ; tabs
               :autoindent true
               :cindent true
               :tabstop 2
               :shiftwidth 2
               :softtabstop 2
               :expandtab true
               ; begone "HIT ENTER" prompt
               :messagesopt "hit-enter,history:500"
               ; folding
               ; set default, override in ftplugin
               :foldmethod :manual
               ; open most folds when opening files
               :foldlevel 4
               ; show up to 4 columns showing all folds
               ; :foldcolumn "auto:4"
               ; what kinds of commands open folds if the cursor ends up in them
               ; let's update to include jumps so G[number] opens the fold
               :foldopen "block,hor,jump,mark,percent,quickfix,search,tag,undo"}]
  (each [option value (pairs options)]
    (tset vim.o option value)))

(local custom-ftplugins [:fennel
                         :gitconfig
                         :javascript
                         :markdown
                         :neogitstatus
                         :outline
                         :qf
                         :typescript])

(vim.api.nvim_create_autocmd :FileType
                             {:pattern custom-ftplugins
                              :desc "Load custom Fennel ftplugins"
                              :callback (fn [args]
                                          (let [module (.. "ftplugin." args.match)]
                                            (tset package.loaded module nil)
                                            (require module)))})

;;import plugins, kick off plugin config
(require :config.plugin)

; post-plugin setup stuff
(fn start-local-server []
  (vim.cmd :tabnew)
  (vim.cmd :vsplit)
  (vim.cmd "wincmd h")
  (vim.cmd "terminal pnpm app:client")
  (vim.cmd "file term/ui.zsh")
  (vim.cmd "wincmd l")
  (vim.cmd "terminal pnpm app:server")
  (vim.cmd "file term/api.zsh"))

(vim.api.nvim_create_user_command :StartLocalServer start-local-server {})
(vim.api.nvim_set_keymap :n :<leader>sl :<cmd>StartLocalServer<cr>
                         {:desc "Start local droplet server"})
