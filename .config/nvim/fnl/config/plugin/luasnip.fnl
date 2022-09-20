(module config.plugin.luasnip
  {autoload {nvim aniseed.nvim
             ls luasnip
             loaders luasnip.loaders
             as aniseed.string
             core aniseed.core
             load_from_vscode luasnip.loaders.from_vscode}})

(def- this-file (nvim.buf_get_name 0))

(defn edit-snippets []
  "Edit snippets yo"
  (nvim.ex.edit this-file))

; load friendly snippets
(load_from_vscode.lazy_load)

(ls.config.set_config {:history true
                            :update_events "TextChanged,TextChangedI" })

(vim.keymap.set :n :<leader>es loaders.edit_snippet_files {:desc "Edit external snippet files"})
(vim.keymap.set :n :<leader><leader>s edit-snippets {:desc "Edit fnl-defined snippets"})

(defn file-name-to-module-name []
  "Turn a TM_FILENAME from a luasnip thing in to a module name"
  (-> (nvim.buf_get_name 0)
      (as.split "/.config/nvim/fnl/")
      (core.second)
      (string.gsub ".fnl" "")
      ( string.gsub "/" ".")))

(let [t ls.text_node
      i ls.insert_node
      f ls.function_node
      choice ls.choice_node
      node ls.snippet_node
      s ls.snippet]

    (ls.add_snippets "fennel" [
      (s {:trig "nmod" :name "module" :dscr "Add the preamble for a new Neovim module"} 
        [(t "(module ")
         (f file-name-to-module-name)
         ; (i 1 "module_name")
         (t ["" "  {autoload {" ])
         (i 1 "local")
         (t " ")
         (i 2 "import")
         (t [""  "}})"])
         (i 0)])]))
