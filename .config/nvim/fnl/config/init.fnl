(module config.init {autoload {core aniseed.core
                               nvim aniseed.nvim
                               util config.util
                               str aniseed.string}})

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

; make config reload without spamming autocommands
(nvim.clear_autocmds {:event :TextYankPost})
(nvim.create_autocmd :TextYankPost
                     {:pattern "*"
                      :desc "Highlight yanked text"
                      :callback #(vim.highlight.on_yank {:timeout 350
                                                         :on_visual false
                                                         :higroup :IncSearch})})

; au TextYankPost * silent! lua vim.highlight.on_yank()
; to your init.vim. You can customize the highlight group and the duration of the highlight via
; au TextYankPost * silent! lua vim.highlight.on_yank {higroup="IncSearch", timeout=150}
; If you want to exclude visual selections from highlighting on yank, use
; au TextYankPost * silent! lua vim.highlight.on_yank {on_visual=false}

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
               :expandtab true}]
  (each [option value (pairs options)]
    (core.assoc nvim.o option value)))

;import plugin.fnl
(require :config.plugin)
