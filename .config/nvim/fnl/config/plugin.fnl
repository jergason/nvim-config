(module config.plugin {autoload {nvim aniseed.nvim
                                 a aniseed.core
                                 packer packer}})

{}

(defn- safe-require-plugin-config
  [name]
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
; can also use :run for simple plugin setup

;; fnlfmt: skip
(use

     ;; plugin Manager
     :wbthomason/packer.nvim {}
     ;; nvim config and plugins in Fennel
     :Olical/aniseed {:branch :develop}

     ; =======================
     ; Theme/Look/Feel/Feels
     ; =======================
     :cocopon/iceberg.vim {}
     :folke/tokyonight.nvim {}
     :catppuccin/nvim {:as :catppuccin}
     :projekt0n/github-nvim-theme {:mod :theme }
     :nvim-lualine/lualine.nvim {:mod :lualine}
     :akinsho/bufferline.nvim {:mod :bufferline}

     ;; show key mappings
     :folke/which-key.nvim {:mod :which-key}
     ;; parsing system
     ;; NOTE: this doesn't work on first install, since I guess it hasn't loaded the plugin when it tries to run :TSUpdate.
     ;; look at some way to defer this?
     :nvim-treesitter/nvim-treesitter-context {:run ":TSUpdate" 
                                               :mod :treesitter
                                               :requires [:nvim-treesitter/nvim-treesitter
                                                          :nvim-treesitter/playground
                                                          :yorickpeterse/nvim-tree-pairs
                                                          :nvim-treesitter/nvim-treesitter-textobjects ]}




     ;; telescope
     :nvim-telescope/telescope.nvim {:requires [:nvim-telescope/telescope-ui-select.nvim
                                                :nvim-lua/popup.nvim
                                                :nvim-lua/plenary.nvim
                                                :kyazdani42/nvim-web-devicons]
                                     :mod :telescope}
     :nvim-telescope/telescope-fzf-native.nvim {:run :make}

     ;; lsp
     :williamboman/mason.nvim {:mod :mason}

     ; put lsp-related config in a special magic subdir
     :neovim/nvim-lspconfig {:requires [:williamboman/mason-lspconfig.nvim
                                        :hrsh7th/cmp-nvim-lsp
                                        :creativenull/efmls-configs-nvim
                                        :j-hui/fidget.nvim
                                        ;:pmizio/typescript-tools.nvim
                                        ]
                             :mod :lsp.init}

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

     ;; database stuff
     :tpope/vim-dadbod {}
     :kristijanhusak/vim-dadbod-ui {}



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
     ;; clojure/lisp stuff
     ;; repl tools
     :Olical/conjure {:mod :conjure}
     ;; sexp
     :guns/vim-sexp {:mod :sexp}
     :tpope/vim-sexp-mappings-for-regular-people {}
     :clojure-vim/vim-jack-in {:requires [:radenling/vim-dispatch-neovim
                                          :tpope/vim-dispatch]}

     ; javascript
     :pangloss/vim-javascript {}
     :gennaro-tedesco/nvim-jqx {:mod :jqx}

     :ocaml/vim-ocaml {}

     ; infra/ops stuff!
     :hashivim/vim-terraform {}
     :ekalinin/Dockerfile.vim {}

     ; lua stdlib docs in help
     :milisims/nvim-luaref {}
     ; . . . something?
     :folke/lua-dev.nvim {}

     ; markdown
     ; depends on node and yarn being installed already
     :iamcco/markdown-preview.nvim { :run "cd app && yarn install" :mod :markdown-preview }
     :OXY2DEV/markview.nvim {:mod :markview}

     :aklt/plantuml-syntax {:requires [:weirongxu/plantuml-previewer.vim]}


     ; ==============
     ; Utility/Tools
     ; ==============
     :simrat39/symbols-outline.nvim {:mod :symbols-outline}
     :HiPhish/rainbow-delimiters.nvim {}
     ; easily toggle terminal
     :akinsho/toggleterm.nvim {:mod :toggleterm}

     ; =========
     ; AI Magic
     ; =========
     :yetone/avante.nvim { :run ":AvanteBuild"
                           :requires [:stevearc/dressing.nvim
                                      :nvim-lua/plenary.nvim
                                      :MunifTanjim/nui.nvim
                                      :echasnovski/mini.icons] }
     :github/copilot.vim {}
     :olimorris/codecompanion.nvim {
                                    :requires [:stevearc/dressing.nvim
                                               :nvim-lua/plenary.nvim
                                               :nvim-treesitter/nvim-treesitter
                                               :nvim-telescope/telescope.nvim ] }

     :jackMort/ChatGPT.nvim {:requires [:MunifTanjim/nui.nvim]
                             ; NOTE: the ai module setups up all the AI plugins. maybe this is a bad idea? but for now I find myself messing with them all together.
                             :mod :ai}

     :Isrothy/neominimap.nvim {:mod :neominimap}

     :tyru/open-browser.vim {:mod :open-browser}
     :mbbill/undotree {:mod :undotree}
     :skywind3000/asyncrun.vim {}

     :vim-test/vim-test {:mod :vim-test}
     :mistricky/codesnap.nvim {:mod :codesnap :run :make}

     :microsoft/vscode-js-debug {:opt true :run "npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out" }
     :mxsdev/nvim-dap-vscode-js { :mod :dap :requires [:mfussenegger/nvim-dap :nvim-neotest/nvim-nio :rcarriga/nvim-dap-ui] }

     ; ===========================
     ; Git and Version Control
     ; ===========================
     :NeogitOrg/neogit {:mod :neogit :requires [:nvim-lua/plenary.nvim]}
     :tpope/vim-fugitive {:mod :fugitive}
     ; Gitsigns toggle_current_line_blame will show inline blame
     :lewis6991/gitsigns.nvim { :mod :gitsigns } 

     :tpope/vim-rhubarb {}
     :pwntester/octo.nvim {:requires [:nvim-lua/plenary.nvim :kyazdani42/nvim-web-devicons]
                           :mod :octo}
)

