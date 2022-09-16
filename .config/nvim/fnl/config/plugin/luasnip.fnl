(module config.plugin.luasnip
  {autoload {nvim aniseed.nvim
             luasnip luasnip
             loaders luasnip.loaders
             load_from_vscode luasnip.loaders.from_vscode}})

(def- this-file "~/.config/nvim/fnl/config/plugin/luasnip.fnl")

(defn reload-snippets []
  "Reload snippets."
  (nvim.ex.AniseedEvalFile this-file)
  (nvim.echo "snippets reloaded"))

(defn edit-snippets []
  "Edit snippets yo"
  (nvim.ex.edit this-file))

; load friendly snippets
(load_from_vscode.lazy_load)

(luasnip.config.set_config {:history true
                            :update_events "TextChanged,TextChangedI" })


(vim.keymap.set :n :<leader>es loaders.edit_snippet_files {:desc "Edit external snippet files"})
; reload snippets to support live-reloading them
; TODO: how to make this source the current  file?
; I don't really need this if I have conjure running I guess, can just evaluate the buffer
;(vim.keymap.set :n :<leader><leader>s reload-snippets)
(vim.keymap.set :n :<leader><leader>s edit-snippets {:desc "Edit fnl-defined snippets"})
