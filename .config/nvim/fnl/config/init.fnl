(module config.init {autoload {core aniseed.core
                               nvim aniseed.nvim
                               util config.util
                               str aniseed.string
                               c aniseed.compile}})

;generic mapping leaders configuration
(nvim.set_keymap :n :<space> :<nop> {:noremap true})
(set nvim.g.mapleader " ")
(set nvim.g.maplocalleader " ")

; enable :Cfilter for qfix list
(nvim.ex.packadd :cfilter)

;hit enter to clear search highlights
(nvim.set_keymap :n :<Enter> :<cmd>nohlsearch<cr> {})

; faster exiting terminal mode
(nvim.set_keymap :t :<C-w> "<C-\\><C-n>"
                 {:noremap true :desc "Exit terminal insert mode"})

;remove trailing whitespace
(util.nnoremap :ws "%s/\\s\\+$//e")
; I always hit this on the kinesis, just disable it
(nvim.set_keymap :n :<F1> :<Nop> {})

; highlight yanked text
(nvim.clear_autocmds {:event :TextYankPost})
(nvim.create_autocmd :TextYankPost
                     {:pattern "*"
                      :desc "Highlight yanked text"
                      :callback #(vim.highlight.on_yank {:timeout 350
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
               ; tabs
               :autoindent true
               :cindent true
               :tabstop 2
               :shiftwidth 2
               :softtabstop 2
               ; default is 4000, but make it shorter so gitgutter works faster
               :updatetime 500
               :expandtab true
               ; folding
               ; set default
               :foldmethod :manual
               ; show up to 4 columns showing all folds
               ; :foldcolumn "auto:4"
               ; what kinds of commands open folds if the cursor ends up in them
               ; let's update to include jumps so G[number] opens the fold
               :foldopen "block,hor,jump,mark,percent,quickfix,search,tag,undo"}]
  (each [option value (pairs options)]
    (core.assoc nvim.o option value)))

; TODO: avoid hard-coding this, can I get the path to this file somehow?
(def fnl-ftplugin-path (vim.fs.normalize "~/.config/nvim/fnl/ftplugin"))
(def ftplugin-path (vim.fs.normalize "~/.config/nvim/ftplugin"))
; compile ftplugin separately since aniseed doesn't make it easy to have input and output dirs the same
(c.glob :*.fnl fnl-ftplugin-path ftplugin-path)

;;import plugins, kick off plugin config
(require :config.plugin)
