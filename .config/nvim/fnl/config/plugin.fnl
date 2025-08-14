(module config.plugin {autoload {nvim aniseed.nvim a aniseed.core lazy lazy}})

; plugins managed by lazy.nvim
; :1 is the plugin URL that gets expanded to github
; lazy.nvim loads plugins lazily by default

(lazy.setup [; =======================
             ; Theme/Look/Feel/Feels  
             ; =======================
             ;{1 :cocopon/iceberg.vim :lazy false}
             {1 :folke/tokyonight.nvim :lazy false}
             ;{1 :catppuccin/nvim :name :catppuccin :lazy false}
             {1 :projekt0n/github-nvim-theme
              :config #(require :config.plugin.theme)
              :lazy false}
             {1 :nvim-lualine/lualine.nvim
              :config #(require :config.plugin.lualine)}
             {1 :akinsho/bufferline.nvim
              :config #(require :config.plugin.bufferline)}
             ; show key mappings
             {1 :folke/which-key.nvim
              :config #(require :config.plugin.which-key)}
             ; parsing system
             {1 :nvim-treesitter/nvim-treesitter-context
              :build ":TSUpdate"
              :lazy false
              :config #(require :config.plugin.treesitter)
              :dependencies [:nvim-treesitter/nvim-treesitter
                             :nvim-treesitter/playground
                             ; {1 :OXY2DEV/markview.nvim
                             ;  :config #(require :config.plugin.markview)}
                             :yorickpeterse/nvim-tree-pairs
                             :nvim-treesitter/nvim-treesitter-textobjects]}
             ; telescope
             {1 :nvim-telescope/telescope.nvim
              :dependencies [:nvim-telescope/telescope-ui-select.nvim
                             :nvim-lua/popup.nvim
                             {1 :nvim-telescope/telescope-fzf-native.nvim
                              :build :make}
                             :nvim-lua/plenary.nvim
                             :kyazdani42/nvim-web-devicons]
              :config #(require :config.plugin.telescope)}
             ; lsp
             {1 :williamboman/mason.nvim
              :config #(require :config.plugin.mason)}
             ; put lsp-related config in a special magic subdir
             {1 :neovim/nvim-lspconfig
              :dependencies [:hrsh7th/cmp-nvim-lsp
                             :creativenull/efmls-configs-nvim
                             :j-hui/fidget.nvim]
              :config #(require :config.plugin.lsp.init)}
             {1 :folke/trouble.nvim :config #(require :config.plugin.trouble)}
             ; autocomplete
             {1 :hrsh7th/nvim-cmp
              :dependencies [:hrsh7th/cmp-buffer
                             :hrsh7th/cmp-nvim-lsp
                             :hrsh7th/cmp-path
                             :hrsh7th/cmp-nvim-lua
                             :PaterJason/cmp-conjure]
              :config #(require :config.plugin.cmp)}
             ; tim pope vim pope
             :tpope/vim-eunuch
             :tpope/vim-jdaddy
             :tpope/vim-repeat
             :tpope/vim-surround
             :tpope/vim-vinegar
             ; ================
             ; Language Support
             ; ================
             ; 
             ; ------------------
             ; clojure/lisp stuff
             ; ------------------
             {1 :Olical/conjure :config #(require :config.plugin.conjure)}
             {1 :guns/vim-sexp :config #(require :config.plugin.sexp)}
             ; "tpope/vim-sexp-mappings-for-regular-people"
             ; {1 "clojure-vim/vim-jack-in" 
             ;  :dependencies ["radenling/vim-dispatch-neovim"
             ;                 "tpope/vim-dispatch"]}
             ; -----------
             ; javascript/web
             ; -----------
             :pangloss/vim-javascript
             {1 :gennaro-tedesco/nvim-jqx
              :config #(require :config.plugin.jqx)}
             ; ----------------
             ; infra/ops stuff!
             ; ----------------
             :hashivim/vim-terraform
             :ekalinin/Dockerfile.vim
             ; lua stdlib docs in help
             :milisims/nvim-luaref
             ; . . . something?
             :folke/lua-dev.nvim
             ; markdown
             :MeanderingProgrammer/render-markdown.nvim
             ; depends on node and yarn being installed already
             ; {1 :iamcco/markdown-preview.nvim
             ;  :build "cd app && yarn install"
             ;  :config #(require :config.plugin.markdown-preview)}
             ; ==============
             ; Utility/Tools
             ; ==============
             ; forked from https://github.com/simrat39/symbols-outline.nvim
             ; with some changes pulled in from https://github.com/vaengir/symbols-outline.nvim
             {1 :jergason/symbols-outline.nvim
              :config #(require :config.plugin.symbols-outline)}
             :HiPhish/rainbow-delimiters.nvim
             ; easily toggle terminal
             {1 :akinsho/toggleterm.nvim
              :config #(require :config.plugin.toggleterm)}
             ; =========
             ; AI Magic
             ; =========
             {1 :greggh/claude-code.nvim
              :dependencies [:nvim-lua/plenary.nvim]
              :opts {:keymaps {:toggle {:normal :<leader>cl}}}}
             {1 :github/copilot.vim :config #(require :config.plugin.copilot)}
             ; ============
             ; Other Config
             ; ============
             {1 :chrisgrieser/nvim-early-retirement}
             {1 :Isrothy/neominimap.nvim
              :config #(require :config.plugin.neominimap)}
             {1 :tyru/open-browser.vim
              :config #(require :config.plugin.open-browser)}
             ; {1 "mbbill/undotree" :config #(require :config.plugin.undotree)}
             ; "skywind3000/asyncrun.vim"
             ; {1 "microsoft/vscode-js-debug" 
             ;  :lazy true 
             ;  :build "npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out"}
             ; {1 "mxsdev/nvim-dap-vscode-js" 
             ;  :config #(require :config.plugin.dap) 
             ;  :dependencies ["mfussenegger/nvim-dap" "nvim-neotest/nvim-nio" "rcarriga/nvim-dap-ui"]}
             ; ===========================
             ; Git and Version Control
             ; ===========================
             {1 :NeogitOrg/neogit
              :config #(require :config.plugin.neogit)
              :dependencies [:nvim-lua/plenary.nvim
                             ; used for diffing
                             :sindrets/diffview.nvim]}
             {1 :tpope/vim-fugitive :config #(require :config.plugin.fugitive)}
             {1 :lewis6991/gitsigns.nvim
              :config #(require :config.plugin.gitsigns)}
             :tpope/vim-rhubarb
             {1 :pwntester/octo.nvim
              :dependencies [:nvim-lua/plenary.nvim
                             :kyazdani42/nvim-web-devicons]
              :config #(require :config.plugin.octo)}])
