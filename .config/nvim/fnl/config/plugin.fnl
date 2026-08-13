(local lazy (require :lazy))

; plugins managed by lazy.nvim
; :1 is the plugin URL that gets expanded to github
; lazy.nvim loads plugins lazily by default

(lazy.setup [{1 :Olical/nfnl :ft :fennel}
             ; =======================
             ; Theme/Look/Feel/Feels
             ; =======================
             {1 :folke/tokyonight.nvim
              :lazy false
              :config #(vim.cmd "colorscheme tokyonight")}
             {1 :nvim-mini/mini.nvim :config #(require :config.plugin.mini)}
             ; parsing system
             {1 :nvim-treesitter/nvim-treesitter-context
              :build ":TSUpdate"
              :lazy false
              :config #(require :config.plugin.treesitter)
              :dependencies [{1 :nvim-treesitter/nvim-treesitter :branch :main}
                             :yorickpeterse/nvim-tree-pairs
                             {1 :nvim-treesitter/nvim-treesitter-textobjects
                              :branch :main}]}
             ; picker backends (telescope replacement)
             {1 :dmtrKovalenko/fff.nvim
              :build #(let [download (require :fff.download)]
                        (download.download_or_build_binary))
              :opts {:debug {:enabled false :show_scores false}}
              :lazy false}
             ; lsp
             {1 :williamboman/mason.nvim
              :config #(require :config.plugin.mason)}
             ; put lsp-related config in a special magic subdir
             {1 :neovim/nvim-lspconfig
              :dependencies [:hrsh7th/cmp-nvim-lsp
                             :creativenull/efmls-configs-nvim
                             :j-hui/fidget.nvim]
              :config #(require :config.plugin.lsp.init)}
             ; {1 :folke/trouble.nvim :config #(require :config.plugin.trouble)}
             ; autocomplete
             {1 :hrsh7th/nvim-cmp
              :dependencies [:hrsh7th/cmp-buffer
                             :hrsh7th/cmp-nvim-lsp
                             :hrsh7th/cmp-path
                             :hrsh7th/cmp-nvim-lua]
              :config #(require :config.plugin.cmp)}
             ; tim pope vim pope
             :tpope/vim-jdaddy
             :tpope/vim-repeat
             ; ================
             ; Language Support
             ; ================
             ; ------------------
             ; clojure/lisp stuff
             ; ------------------
             {1 :guns/vim-sexp :config #(require :config.plugin.sexp)}
             ; -----------
             ; javascript/web
             ; -----------
             ; ----------------
             ; infra/ops stuff!
             ; ----------------
             :hashivim/vim-terraform
             :ekalinin/Dockerfile.vim
             ; lua stdlib docs in help
             :milisims/nvim-luaref
             ; . . . something?
             ; :folke/lua-dev.nvim
             ; markdown
             :MeanderingProgrammer/render-markdown.nvim
             ; depends on node and yarn being installed already
             {1 :iamcco/markdown-preview.nvim
              :build "cd app && npm install && git restore ."
              :cmd [:MarkdownPreviewToggle
                    :MarkdownPreview
                    :MarkdownPreviewStop]
              :ft [:markdown]
              :config #(require :config.plugin.markdown-preview)}
             ; ==============
             ; Utility/Tools
             ; ==============
             ; forked from https://github.com/simrat39/symbols-outline.nvim
             ; with some changes pulled in from https://github.com/vaengir/symbols-outline.nvim
             {1 :jergason/symbols-outline.nvim
              :config #(require :config.plugin.symbols-outline)}
             {1 :HiPhish/rainbow-delimiters.nvim
              :config #(require :config.plugin.rainbow-delimiters)}
             ; clean up old buffers so lsp doesn't explode
             {1 :axkirillov/hbac.nvim :config true}
             ; ============
             ; Other Config
             ; ============
             {1 :tyru/open-browser.vim
              :config #(require :config.plugin.open-browser)}
             ; super secret droplet codebase plugin
             {1 :drplt/droplet-nav-helper-editor-extension
              :dir (vim.fn.expand "~/code/droplet-nav-helper-editor-extension")
              :build "pnpm install && pnpm run build"
              :config (fn [plugin]
                        (vim.opt.rtp:append (.. plugin.dir "/nvim"))
                        (let [droplet-nav (require :droplet-nav)]
                          (droplet-nav.setup)))}
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
             ; {1 :pwntester/octo.nvim
             ;  :dependencies [:nvim-lua/plenary.nvim
             ;                 :kyazdani42/nvim-web-devicons]
             ;  :config #(require :config.plugin.octo)}
             ])
