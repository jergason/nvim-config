(module config.plugin {autoload {nvim aniseed.nvim
                                 a aniseed.core
                                 packer packer}})

(defn- safe-require-plugin-config [name]
       ; pcall is a lua thing - https://www.lua.org/pil/8.4.html. basically, handle errors thrown by requiring each plugin
       ; require is a lua API thing. See :help lua-require
       (let [(ok? val-or-err) (pcall require (.. :config.plugin. name))]
         (when (not ok?)
           (print (.. "config error: " val-or-err)))))

(defn- use [...] "Iterates through the arguments as pairs and calls packer's use function for
  each of them. Works around Fennel not liking mixed associative and sequential
  tables as well."
       (let [pkgs [...]]
         (packer.startup (fn [use]
                           (for [i 1 (a.count pkgs) 2]
                             (let [name (. pkgs i)
                                   opts (. pkgs (+ i 1))]
                               (-?> (. opts :mod) (safe-require-plugin-config))
                               (use (a.assoc opts 1 name))))))) nil)

;;; plugins managed by packer
;;; :mod specifies namespace under plugin directory

; fnl formatting absolutely MURDERS this

;; fnlfmt: skip
(use

     ;; plugin Manager
     :wbthomason/packer.nvim {}
     ;; nvim config and plugins in Fennel
     :Olical/aniseed {:branch :develop}
     
     ;; repl tools
     :Olical/conjure {:branch :master :mod :conjure}
     ;; show key mappings
     :folke/which-key.nvim {:mod :which-key}
     ;; parsing system
     :nvim-treesitter/nvim-treesitter {:run ":TSUpdate" :mod :treesitter}
     :nvim-treesitter/playground {}

     ;; lsp
     :williamboman/mason.nvim {:mod :mason}
     ; put lsp-related config in a special magic subdir
     :neovim/nvim-lspconfig {:requires [:williamboman/mason-lspconfig.nvim
                                        :jose-elias-alvarez/null-ls.nvim
                                        :j-hui/fidget.nvim] 
                             :mod :lsp.init}

     ; https://github.com/simrat39/symbols-outline.nvim/pull/169 pr fixes showing more symbols in JSX
     ; close when this gets merged in
     :mxsdev/symbols-outline.nvim {:mod :symbols-outline :branch "merge-jsx-tree" }
     ;:simrat39/symbols-outline.nvim {:mod :symbols-outline}

     ;; theme
     :projekt0n/github-nvim-theme {:mod :theme}
     :gennaro-tedesco/nvim-jqx {:mod :jqx}

     :nvim-lualine/lualine.nvim {:mod :lualine}
     :akinsho/bufferline.nvim {:mod :bufferline}
     ; easily toggle terminal
     :Hvassaa/sterm.nvim {:mod :sterm}

     ;; telescope
     :nvim-telescope/telescope.nvim {:requires [:nvim-telescope/telescope-ui-select.nvim
                                                :nvim-lua/popup.nvim
                                                :nvim-lua/plenary.nvim
                                                :kyazdani42/nvim-web-devicons]
                                     :mod :telescope}
     ; faster finding
     :nvim-telescope/telescope-fzf-native.nvim {:run :make}

     ;; LUA STUFF
     ;; lua stdlib docs in help
     :milisims/nvim-luaref {}
     ;; . . . something?
     :folke/lua-dev.nvim {}

     :aklt/plantuml-syntax {:requires [:weirongxu/plantuml-previewer.vim]}

     :tyru/open-browser.vim {:mod :open-browser}

     ;; sexp
     :guns/vim-sexp {:mod :sexp}
     :tpope/vim-sexp-mappings-for-regular-people {}

     ;tim pope vim pope
     :tpope/vim-unimpaired {}
     :tpope/vim-commentary {}
     :tpope/vim-eunuch {}
     :tpope/vim-jdaddy {}
     :tpope/vim-repeat {}
     :tpope/vim-surround {}
     :tpope/vim-vinegar {}

     :nvim-orgmode/orgmode {:mod :orgmode}

     ;; snippets
     :L3MON4D3/LuaSnip {:requires [:saadparwaiz1/cmp_luasnip
                                  :rafamadriz/friendly-snippets]
                       :mod :luasnip}

     ;; autocomplete
     :hrsh7th/nvim-cmp {:requires [:hrsh7th/cmp-buffer
                                  :hrsh7th/cmp-nvim-lsp
                                  :hrsh7th/cmp-path
                                  :hrsh7th/cmp-nvim-lua
                                  :PaterJason/cmp-conjure]
                       :mod :cmp}

     :mbbill/undotree {:mod :undotree}
     :vim-test/vim-test {:mod :vim-test}

     :pangloss/vim-javascript {}
     :dart-lang/dart-vim-plugin {}

     ;; git/github
     :airblade/vim-gitgutter {}
     :tpope/vim-fugitive {:mod :fugitive}
     :tpope/vim-rhubarb {}
     :pwntester/octo.nvim {:requires [:nvim-lua/plenary.nvim :kyazdani42/nvim-web-devicons]
      :mod :octo}
     )
