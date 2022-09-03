(module config.plugin
  {autoload {nvim aniseed.nvim
             a aniseed.core
             packer packer}})

(defn- safe-require-plugin-config [name]
  ; pcall is a lua thing - https://www.lua.org/pil/8.4.html. basically, handle errors thrown by requiring each plugin
  ; require is a lua API thing. See :help lua-require
  (let [(ok? val-or-err) (pcall require (.. :config.plugin. name))]
    (when (not ok?)
      (print (.. "config error: " val-or-err)))))

(defn- use [...]
  "Iterates through the arguments as pairs and calls packer's use function for
  each of them. Works around Fennel not liking mixed associative and sequential
  tables as well."
  (let [pkgs [...]]
    (packer.startup
      (fn [use]
        (for [i 1 (a.count pkgs) 2]
          (let [name (. pkgs i)
                opts (. pkgs (+ i 1))]
            (-?> (. opts :mod) (safe-require-plugin-config))
            (use (a.assoc opts 1 name)))))))
  nil)

;;; plugins managed by packer
;;; :mod specifies namespace under plugin directory

(use

  ;; plugin Manager
  :wbthomason/packer.nvim {}
  ;; nvim config and plugins in Fennel
  :Olical/aniseed {:branch :develop}

  ;; show key mappings
  :folke/which-key.nvim {:mod :which-key}

  ;; parsing system
  :nvim-treesitter/nvim-treesitter {:run ":TSUpdate"
                                    :mod :treesitter}

  ;; lsp
  :williamboman/mason.nvim { :mod :mason }
  :williamboman/mason-lspconfig.nvim { :mod :mason-lspconfig }
  :neovim/nvim-lspconfig { :mod :lspconfig }

  :simrat39/symbols-outline.nvim { :mod :symbols-outline }

  ;; theme
  :projekt0n/github-nvim-theme {:mod :theme}

  ;; status line
  :nvim-lualine/lualine.nvim {:mod :lualine}

  ;; file searching
  :nvim-telescope/telescope.nvim {:requires [:nvim-telescope/telescope-ui-select.nvim
                                             :nvim-lua/popup.nvim
                                             :nvim-lua/plenary.nvim
                                             ; for frecency
                                             :kkharji/sqlite.lua
                                             :nvim-telescope/telescope-frecency.nvim
                                             :kyazdani42/nvim-web-devicons]
                                  :mod :telescope}

  ;; LUA STUFF

  ;; lua stdlib docs in help
  :milisims/nvim-luaref {}
  ;; . . . something?
  :folke/lua-dev.nvim {}

  :kosayoda/nvim-lightbulb {:requires [:antoinemadec/FixCursorHold.nvim]
                            :mod :lightbulb}

  :weilbith/nvim-code-action-menu {:mod :code-action}

  ;; repl tools
  :Olical/conjure {:branch :master :mod :conjure}

  ;; sexp
  :guns/vim-sexp {:mod :sexp}
  :tpope/vim-sexp-mappings-for-regular-people {}
  :tpope/vim-repeat {}
  :tpope/vim-surround {}


  ;; org mode stuff!
  :nvim-orgmode/orgmode {:mod :orgmode}

  ;; snippets
  :L3MON4D3/LuaSnip {:requires [:saadparwaiz1/cmp_luasnip]}

  ;; autocomplete
  :hrsh7th/nvim-cmp {:requires [:hrsh7th/cmp-buffer
                                :hrsh7th/cmp-nvim-lsp
                                :hrsh7th/cmp-path
                                :PaterJason/cmp-conjure]
                     :mod :cmp}

  :mbbill/undotree {:mod :undotree}

  :pangloss/vim-javascript {}

  ;;:tpope/vim-vinegar {}
  ;; seems like this goofs up copy-pasting stuff?


  ; replaced w/ telescope file_picker
  ; :mcchrish/nnn.vim {}

  ;; dart stuff
  :dart-lang/dart-vim-plugin {}

  ;; git/github
  :airblade/vim-gitgutter {}

  :tpope/vim-fugitive {:mod :fugitive}
  :tpope/vim-rhubarb {}

  :pwntester/octo.nvim   {:requires [:nvim-lua/plenary.nvim
                                     :nvim-telescope/telescope.nvim
                                     :kyazdani42/nvim-web-devicons]
                          :mod :octo}
  ;:github/copilot.vim {}
  )

