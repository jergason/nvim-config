(module config.plugin {autoload {nvim aniseed.nvim
                                 a aniseed.core
                                 packer packer}})

(defn- safe-require-plugin-config
  [name] ; pcall is a lua thing - https://www.lua.org/pil/8.4.html. basically, handle errors thrown by requiring each plugin
  ; require is a lua API thing. See :help lua-require
  (let [(ok? val-or-err) (pcall require (.. :config.plugin. name))]
    (when (not ok?)
      (print (.. "config error: " val-or-err)))))

(defn- use
  [...]
  "Iterates through the arguments as pairs and calls packer's use function for
  each of them. Works around Fennel not liking mixed associative and sequential
  tables as well."
  (let [pkgs [...]]
    (packer.startup (fn [use]
                      (for [i 1 (a.count pkgs) 2]
                        (let [name (. pkgs i)
                              opts (. pkgs (+ i 1))]
                          (-?> (. opts :mod) (safe-require-plugin-config))
                          (use (a.assoc opts 1 name)))))))
  nil)

; plugins managed by packer
; :mod specifies namespace under plugin directory
; fnl formatting absolutely MURDERS this, so turn it off

;; fnlfmt: skip
(use

     ;; plugin Manager
     :wbthomason/packer.nvim {}
     ;; nvim config and plugins in Fennel
     :Olical/aniseed {:branch :develop}

     ;; theme and look/feel
     :projekt0n/github-nvim-theme {:mod :theme }
     :cocopon/iceberg.vim {}
     :folke/tokyonight.nvim {}
     :nvim-lualine/lualine.nvim {:mod :lualine}
     :akinsho/bufferline.nvim {:mod :bufferline}

     ;; clojure/lisp stuff
     ;; repl tools
     :Olical/conjure {:mod :conjure}
     ;; sexp
     :guns/vim-sexp {:mod :sexp}
     :tpope/vim-sexp-mappings-for-regular-people {}
     :clojure-vim/vim-jack-in {:requires [:radenling/vim-dispatch-neovim
                                          :tpope/vim-dispatch]}


     ;; show key mappings
     :folke/which-key.nvim {:mod :which-key}
     ;; parsing system
     ;; NOTE: this doesn't work on first install, since I guess it hasn't loaded the plugin when it tries to run :TSUpdate.
     ;; look at some way to defer this?
     :nvim-treesitter/nvim-treesitter {:run ":TSUpdate" 
                                       :mod :treesitter
                                       :requires [:nvim-treesitter/nvim-treesitter-context
                                                  :nvim-treesitter/playground
                                                  :nvim-treesitter/nvim-treesitter-textobjects ]}




     ;; telescope
      :nvim-telescope/telescope.nvim {:requires [:nvim-telescope/telescope-ui-select.nvim
                                                :nvim-lua/popup.nvim
                                                :nvim-lua/plenary.nvim
                                                :kyazdani42/nvim-web-devicons]
                                     :mod :telescope}

     ;; lsp
     :williamboman/mason.nvim {:mod :mason}

     ; put lsp-related config in a special magic subdir
     :neovim/nvim-lspconfig {:requires [:williamboman/mason-lspconfig.nvim
                                        ;:jose-elias-alvarez/null-ls.nvim
                                        :hrsh7th/cmp-nvim-lsp
                                        :j-hui/fidget.nvim
                                        :pmizio/typescript-tools.nvim]
                             :mod :lsp.init}

     ; linting for stuff that doesn't provide an LSP directly
     :mfussenegger/nvim-lint { :mod :lint }

     ; formatting for stuff that doesn't provide formatting via lsp
     :stevearc/conform.nvim { :mod :format }

     :folke/trouble.nvim { :mod :trouble }

     ;; autocomplete
     :hrsh7th/nvim-cmp {:requires [:hrsh7th/cmp-buffer
                                  :hrsh7th/cmp-nvim-lsp
                                  :hrsh7th/cmp-path
                                  :hrsh7th/cmp-nvim-lua
                                  :PaterJason/cmp-conjure]
                       :mod :cmp}


     ;; snippets
     :L3MON4D3/LuaSnip {:requires [:saadparwaiz1/cmp_luasnip
                                 :rafamadriz/friendly-snippets]
                      :mod :luasnip}

     :simrat39/symbols-outline.nvim {:mod :symbols-outline}

     :HiPhish/rainbow-delimiters.nvim {}

     ; easily toggle terminal
     :Hvassaa/sterm.nvim {:mod :sterm}

     :jackMort/ChatGPT.nvim {:requires [:MunifTanjim/nui.nvim]
                             :mod :ai}

     ; faster finding
      :nvim-telescope/telescope-fzf-native.nvim {:run :make}


     :aklt/plantuml-syntax {:requires [:weirongxu/plantuml-previewer.vim]}

     :tyru/open-browser.vim {:mod :open-browser}


     ;tim pope vim pope
     :tpope/vim-unimpaired {}
     :tpope/vim-commentary {}
     :tpope/vim-eunuch {}
     :tpope/vim-jdaddy {}
     :tpope/vim-repeat {}
     :tpope/vim-surround {}
     :tpope/vim-vinegar {}


     ; ================
     ; Language Support
     ; ================

     ; javascript
     :pangloss/vim-javascript {}
     :gennaro-tedesco/nvim-jqx {:mod :jqx}

     :ocaml/vim-ocaml {}

     ; infra/ops stuff!
     :hashivim/vim-terraform {}
     :ekalinin/Dockerfile.vim {}

     ;; LUA STUFF
     ;; lua stdlib docs in help
     :milisims/nvim-luaref {}
     ;; . . . something?
     :folke/lua-dev.nvim {}

     ; markdown
     ; depends on node and yarn being installed already
     :iamcco/markdown-preview.nvim { :run "cd app && yarn install" :mod :markdown-preview }

     ;:m4xshen/hardtime.nvim {:requires [:nvim-lua/plenary.nvim :MunifTanjim/nui.nvim] :mod :hardtime}


     :mbbill/undotree {:mod :undotree}
     :skywind3000/asyncrun.vim {}

     :vim-test/vim-test {:mod :vim-test}

     ;; git/github
     :NeogitOrg/neogit {:mod :neogit :requires [:nvim-lua/plenary.nvim]}
     :tpope/vim-fugitive {:mod :fugitive}
     :github/copilot.vim {:mod :copilot}

     :tpope/vim-rhubarb {}
     :pwntester/octo.nvim {:requires [:nvim-lua/plenary.nvim :kyazdani42/nvim-web-devicons]
                           :mod :octo}
     )

