(fn lsp-attached? []
  (> (length (vim.lsp.get_clients {:bufnr 0})) 0))

(fn command-exists? [name]
  (= 2 (vim.fn.exists (.. ":" name))))

(fn help-word []
  (let [word (vim.fn.expand "<cword>")]
    (if (= word "")
        (vim.notify "No symbol under cursor" vim.log.levels.WARN)
        (let [result [(pcall vim.cmd (.. "help " word))]
              ok (. result 1)
              err (. result 2)]
          (if (not ok)
              (vim.notify err vim.log.levels.WARN))))))

(fn fennel-doc []
  (if (lsp-attached?)
      (vim.lsp.buf.hover {:border :double :focusable false})
      (if (command-exists? "ConjureDocWord")
          (vim.cmd :ConjureDocWord)
          (help-word))))

(fn fennel-definition []
  (if (lsp-attached?)
      (vim.lsp.buf.definition)
      (if (command-exists? "ConjureDefWord")
          (vim.cmd :ConjureDefWord)
          (vim.notify "No LSP or Conjure definition available"
                      vim.log.levels.WARN))))

(vim.keymap.set :n :K fennel-doc
                {:buffer 0 :desc "Docs (LSP -> Conjure -> help)"})
(vim.keymap.set :n :gd fennel-definition
                {:buffer 0 :desc "Definition (LSP -> Conjure)"})

; TODO: define a command that saves the fnl file and then evaluates it with Conjure
(vim.keymap.set :n "<leader><leader>x"
                (fn []
                  (vim.cmd :write)
                  (vim.cmd :ConjureEval))
                {:buffer 0 :desc "Save and eval current fennel file"})
