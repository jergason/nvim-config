(module config.init
  {autoload {core aniseed.core
             nvim aniseed.nvim
             util config.util
             str aniseed.string}})

;generic mapping leaders configuration
(nvim.set_keymap :n :<space> :<nop> {:noremap true})
(set nvim.g.mapleader " ")
(set nvim.g.maplocalleader " ")

;use tree view for netrw
(set nvim.g.netrw_liststyle 3)
;begone foul banner
(set nvim.g.netrw_banner 0)
;random flailing to try to make copy/paste work in netrw
(set nvim.g.netrw_keepdir 0)
;toggle netrw, poor-mans vinegar
(util.nnoremap :- "Explore!")

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
       ;wrap, but not in the middle of a word
       :wrap true
       :linebreak true
       ;hybrid line numbers
       :nu true
       :rnu true
       ;show whitespace
       :list true
       ;beautify whitespace
       ; TODO for some reason this crashes fennel
       ;:listchars "tab:>-,trail:\\\\u22C5,extends:\\\\u2192,preceeds:\\\\u2190"
       ;transparent floating windows
       :winblend 12
       }]
  (each [option value (pairs options)]
    (core.assoc nvim.o option value)))

;import plugin.fnl
(require :config.plugin)
