(fn lsp-attached? []
  (> (length (vim.lsp.get_clients {:bufnr 0})) 0))

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
      (help-word)))

(fn fennel-definition []
  (if (lsp-attached?)
      (vim.lsp.buf.definition)
      (vim.notify "No LSP definition available" vim.log.levels.WARN)))

(vim.keymap.set :n :K fennel-doc
                {:buffer 0 :desc "Docs (LSP -> help)"})
(vim.keymap.set :n :gd fennel-definition
                {:buffer 0 :desc "Definition (LSP)"})
