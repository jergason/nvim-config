(local t (require :telescope.builtin))
(local cmplsp (require :cmp_nvim_lsp))
(local lspconfig-util (require :lspconfig.util))

(fn find-oxlint-config [bufnr]
  (let [fname (vim.api.nvim_buf_get_name bufnr)]
    (if (not= fname "")
        (let [root-markers (lspconfig-util.insert_package_json [:.oxlintrc.json :oxlint.config.ts]
                                                                :oxlint
                                                                fname)]
          (. (vim.fs.find root-markers
                          {:path fname
                           :upward true
                           :type :file
                           :limit 1})
             1))
        nil)))

(fn project-uses-oxlint? [bufnr]
  (not= nil (find-oxlint-config bufnr)))

(fn oxlint-root-dir [bufnr on-dir]
  (let [config-file (find-oxlint-config bufnr)]
    (if config-file
        (on-dir (vim.fs.dirname config-file)))))

; server features
(fn make-setup-args []
  "return a map of on_attach, handlers, capabilities to pass to `vim.lsp.config` calls"
  {:handlers {:textDocument/publishDiagnostics (vim.lsp.with vim.lsp.diagnostic.on_publish_diagnostics
                                                 {:severity_sort true
                                                  :virtual_text false})
              :textDocument/hover (vim.lsp.with vim.lsp.handlers.hover
                                    {:border :single})
              :textDocument/signatureHelp (vim.lsp.with vim.lsp.handlers.signature_help
                                            {:border :double})}
    :capabilities (cmplsp.default_capabilities (vim.lsp.protocol.make_client_capabilities))
    :on_attach (fn [client bufnr]
                 ; set exit_timeout so neovim's built-in exit handler force-kills
                 ; after 500ms instead of waiting forever (tsgo hangs for 20+s)
                 (tset client :flags :exit_timeout 500)
                 (if (and (= client.name :eslint)
                          (project-uses-oxlint? bufnr))
                     (vim.lsp.stop_client client.id true)
                     (do
                      ; override built-in K to add border and make it not focusable
                      (vim.keymap.set :n :K
                                      #(vim.lsp.buf.hover {:border :double
                                                           :focusable false})
                                      {:buffer bufnr
                                       :desc "LSP: Hover"
                                       :noremap true
                                       :silent true})
                      (vim.keymap.set :n :gd vim.lsp.buf.definition
                                      {:desc "Go to definition" :buffer bufnr})
                      (vim.keymap.set :n :<leader>gh vim.lsp.buf.signature_help
                                      {:buffer bufnr})
                      (vim.keymap.set :n :<leader>rn vim.lsp.buf.rename
                                      {:buffer bufnr})
                      (vim.keymap.set :n :<leader>le vim.diagnostic.open_float
                                      {:buffer bufnr})
                      (vim.keymap.set :n :<leader>lq vim.diagnostic.setqflist
                                      {:buffer bufnr})
                      (vim.keymap.set :n :<leader>lf vim.lsp.buf.format
                                      {:buffer bufnr})
                      (vim.keymap.set :n :<leader>dj vim.diagnostic.goto_next
                                      {:buffer bufnr})
                      (vim.keymap.set :n :<leader>dk vim.diagnostic.goto_prev
                                      {:buffer bufnr})
                      (vim.keymap.set :n :<leader>ca vim.lsp.buf.code_action
                                      {:buffer bufnr})
                      ;telescope
                      (vim.keymap.set :n :<leader>ld
                                      ":lua require('telescope.builtin').diagnostics()<cr>"
                                      {:buffer bufnr})
                      (vim.keymap.set :n :<leader>lr
                                      ":lua require('telescope.builtin').lsp_references()<cr>"
                                      {:buffer bufnr}))))})

(fn lsp-format [bufnr]
  (vim.lsp.buf.format {:filter (fn [client]
                                 (or (= client.name :efm)
                                     (= client.name :efm_prettier)
                                     (= client.name :efm_oxfmt)))}))

(fn read-json-file [path]
  (if (= 1 (vim.fn.filereadable path))
      (let [result [(pcall vim.json.decode (table.concat (vim.fn.readfile path) "\n"))]]
        (if (. result 1)
            (. result 2)
            nil))
      nil))

(fn parse-major-version [version]
  (if version
      (tonumber (string.match (tostring version) "^(%d+)"))
      nil))

(fn normalize-typescript-spec [spec]
  (if spec
      (let [s (vim.trim (tostring spec))
            s (string.gsub s "^workspace:" "")
            s (string.gsub s "^npm:typescript@" "")
            s (string.gsub s "^npm:@typescript/native%-preview@" "")
            s (string.gsub s "^v" "")]
        s)
      nil))

(fn typescript-spec-uses-tsgo? [spec]
  (if spec
      (let [s (normalize-typescript-spec spec)
            direct-major (tonumber (string.match s "^[~^]?([0-9]+)"))
            gte-major (tonumber (string.match s ">=%s*([0-9]+)"))
            gt-major (tonumber (string.match s ">%s*([0-9]+)"))]
        (or (and direct-major (>= direct-major 7))
            (and gte-major (>= gte-major 7))
            (and gt-major (>= gt-major 6))))
      false))

(fn package-dependency-spec [package-json dependency-key]
  (or (vim.tbl_get package-json dependency-key "typescript")
      (vim.tbl_get package-json dependency-key "@typescript/native-preview")))

(fn package-typescript-spec [package-json]
  (if package-json
      (or (package-dependency-spec package-json :dependencies)
          (package-dependency-spec package-json :devDependencies)
          (package-dependency-spec package-json :peerDependencies)
          (package-dependency-spec package-json :optionalDependencies))
      nil))

(fn package-uses-tsgo? [dir]
  (if dir
      (let [installed-typescript (or (read-json-file (.. dir "/node_modules/typescript/package.json"))
                                     (read-json-file (.. dir "/node_modules/@typescript/native-preview/package.json")))
            installed-version (if installed-typescript
                                  (vim.tbl_get installed-typescript :version)
                                  nil)
            installed-major (parse-major-version installed-version)]
        (if installed-major
            (>= installed-major 7)
            (let [package-json (read-json-file (.. dir "/package.json"))
                  declared-spec (package-typescript-spec package-json)]
              (typescript-spec-uses-tsgo? declared-spec))))
      false))

(fn project-uses-tsgo? [bufnr root]
  (let [package-root (vim.fs.root bufnr [:package.json])]
    (or (package-uses-tsgo? package-root)
        (package-uses-tsgo? root))))

(fn default-ts-root-dir [bufnr on-dir]
  (let [root-markers ["package-lock.json" "yarn.lock" "pnpm-lock.yaml" "bun.lockb" "bun.lock" "package.json"]
        root-markers (if (= 1 (vim.fn.has "nvim-0.11.3"))
                         [root-markers [".git"]]
                         (vim.list_extend root-markers [".git"]))]
    (if (vim.fs.root bufnr ["deno.json" "deno.jsonc" "deno.lock"])
        nil
        (let [project-root (vim.fs.root bufnr root-markers)
              fname (vim.api.nvim_buf_get_name bufnr)
              fallback-root (if (not= fname "")
                                (vim.fs.dirname fname)
                                (vim.fn.getcwd))]
          (on-dir (if project-root project-root fallback-root))))))

(fn conditional-root-dir [base-root-dir use-tsgo?]
  (fn [bufnr on-dir]
    (if base-root-dir
        (base-root-dir bufnr
                       (fn [root]
                         (if (= use-tsgo? (project-uses-tsgo? bufnr root))
                             (on-dir root)))))))

(fn conditional-eslint-root-dir [base-root-dir]
  (fn [bufnr on-dir]
    (if (project-uses-oxlint? bufnr)
        nil
        (if base-root-dir
            (base-root-dir bufnr on-dir)))))

(fn _setup []
  (let [setup-args (make-setup-args)
        ts-base-root-dir (or (vim.tbl_get vim.lsp.config :tsgo :root_dir)
                             (vim.tbl_get vim.lsp.config :vtsls :root_dir)
                             default-ts-root-dir)
        eslint-base-root-dir (vim.tbl_get vim.lsp.config :eslint :root_dir)
        eslint-root-dir (conditional-eslint-root-dir eslint-base-root-dir)
        tsgo-root-dir (conditional-root-dir ts-base-root-dir
                                            true)
        vtsls-root-dir (conditional-root-dir ts-base-root-dir
                                             false)]
    (vim.lsp.config "*" setup-args)
    (vim.lsp.config :lua_ls
                    (vim.tbl_deep_extend :force setup-args
                                         {:runtime {:version :LuaJIT}
                                          :diagnostics {:globals [:vim]}
                                          :telemetry {:enable false}}))
    (vim.lsp.config :vtsls
                    (vim.tbl_deep_extend :force setup-args
                                         {:root_dir vtsls-root-dir
                                          :settings {:typescript {:tsserver {:maxTsServerMemory 8192}}}}))
    (vim.lsp.config :tsgo
                    (vim.tbl_deep_extend :force setup-args
                                         {:root_dir tsgo-root-dir}))
    (vim.lsp.config :eslint
                    {:root_dir eslint-root-dir})
    (vim.lsp.config :oxlint
                    (vim.tbl_deep_extend :force setup-args
                                         {:cmd [:oxlint "--lsp"]
                                          :root_dir oxlint-root-dir})))
  (vim.lsp.enable [:bashls :clangd :eslint :gopls :lua_ls :terraformls :tsgo :vtsls :yamlls :oxlint])
  (vim.keymap.set :n :<leader>lf #(lsp-format 0))
  (vim.keymap.set :v :<leader>lf #(lsp-format 0))
  ; neovim's exit hangs because TransportRun:terminate() sends SIGTERM
  ; (tsgo takes 20+s to die) and the built-in VimLeavePre handler's
  ; force-kill logic is broken. fix: SIGKILL + replace exit handler.
  (let [transport (require :vim.lsp._transport)]
    (set transport.TransportRun.terminate
         (fn [self]
           (when self.sysobj
             (self.sysobj:kill 9)))))
  ; delete built-in VimLeavePre handler and replace with fast one
  (let [autocmds (vim.api.nvim_get_autocmds {:event :VimLeavePre})]
    (each [_ ac (ipairs autocmds)]
      (when (= ac.desc "vim.lsp: exit handler")
        (vim.api.nvim_del_autocmd ac.id))))
  (vim.api.nvim_create_autocmd :VimLeavePre
                               {:desc "fast lsp exit"
                                :callback (fn []
                                            (let [pid (vim.fn.getpid)]
                                              ; collect child process groups BEFORE killing
                                              (local pgids {})
                                              (let [h (io.popen (string.format
                                                                  "ps -o pgid= -p $(pgrep -P %d 2>/dev/null | tr '\\n' ',') 2>/dev/null"
                                                                  pid))]
                                                (when h
                                                  (each [line (h:lines)]
                                                    (let [pgid (line:match "(%d+)")]
                                                      (when (and pgid (not= pgid (tostring pid)))
                                                        (tset pgids pgid true))))
                                                  (h:close)))
                                              ; SIGKILL all RPC transports
                                              (each [_ client (ipairs (vim.lsp.get_clients))]
                                                (pcall #(client.rpc.terminate)))
                                              ; SIGKILL all collected process groups
                                              (each [pgid _ (pairs pgids)]
                                                (os.execute (string.format "kill -9 -%s 2>/dev/null" pgid)))
                                              ; spin event loop to process exit events
                                              (vim.wait 500 #(= (length (vim.lsp.get_clients)) 0) 25)))}))

(var is-loaded false)

(fn setup []
  (if (not is-loaded)
      (do
        (_setup)
        (set is-loaded true))))

{: setup : make-setup-args}
