(module config.init
  {autoload {core aniseed.core
             nvim aniseed.nvim
             util config.util
             str aniseed.string}})

;generic mapping leaders configuration
(nvim.set_keymap :n :<space> :<nop> {:noremap true})
(set nvim.g.mapleader " ")
(set nvim.g.maplocalleader " ")

; netrw tree view
; seems like this disables vinegar?
;(set nvim.g.netrw_liststyle 3)

; see if this fixes tab things?
;(set nvim.o.tabstop 2)
;(set nvim.o.expandtab true)

; enable :Cfilter for qfix list
(nvim.ex.packadd :cfilter)

;hit enter to clear search highlights
(nvim.set_keymap :n :<Enter> "<cmd>nohlsearch<cr>" {})

;remove trailing whitespace
(util.nnoremap :ws "%s/\\s\\+$//e")

(let [options
      {;settings needed for cmp autocompletion
       :completeopt "menu,menuone,noselect"
       ;case insensitive search
       :ignorecase true
       ;smart search case
       :smartcase true
       ;shared clipboard with os
       :clipboard "unnamedplus"

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
       :expandtab true


       }]
  (each [option value (pairs options)]
    (core.assoc nvim.o option value)))

;import plugin.fnl
(require :config.plugin)
