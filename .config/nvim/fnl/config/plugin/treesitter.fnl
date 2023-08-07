(module config.plugin.treesitter
        {autoload {treesitter nvim-treesitter.configs ctx treesitter-context}})

; 300 KB
(def max-file-size (* 1024 300))

; large file stuff to look at 
; https://www.reddit.com/r/neovim/comments/12n5lvl/how_do_you_deal_with_large_files/
; https://github.com/nvim-treesitter/nvim-treesitter/pull/3570/files
; https://www.reddit.com/r/neovim/comments/xskdwc/how_to_disable_lsp_and_treesitter_for_huge_file/
; https://www.vim.org/scripts/script.php?script_id=1506

(fn disable-for-large-fies [lang buffer]
  (let [[ok stats] (pcall vim.loop.fs_stat (vim.api.nvim_buf_get_name buffer))]
    (and ok (> (. stats :filesize) max-file-size))))

(treesitter.setup {:highlight {:enable true}
                   ; is this what's messing up my formatting?
                   ; :indent {:enable true }
                   :textobjects {:enable true}
                   :incremental_selection {:enable true}
                   :disable disable-for-large-fies
                   :ensure_installed :all})

(ctx.setup {:separator "-" :max_lines 5 :min_window_height 20})
