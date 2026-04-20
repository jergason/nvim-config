(local picker (require :config.picker))
(local cmplsp (require :cmp_nvim_lsp))
(local lspconfig-util (require :lspconfig.util))

(fn find-oxlint-config [bufnr]
  (let [fname (vim.api.nvim_buf_get_name bufnr)]
    (if (not= fname "")
        (let [root-markers (lspconfig-util.insert_package_json [:.oxlintrc.json
                                                                :oxlint.config.ts]
                                                               :oxlint fname)]
          (. (vim.fs.find root-markers
                          {:path fname :upward true :type :file :limit 1})
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
  "return a map of on_attach, capabilities, flags to pass to `vim.lsp.config` calls"
  {:capabilities (cmplsp.default_capabilities (vim.lsp.protocol.make_client_capabilities))
   :flags {:exit_timeout 500}
   :on_attach (fn [client bufnr]
                (if (and (= client.name :eslint) (project-uses-oxlint? bufnr))
                    (vim.lsp.stop_client client.id true)
                    (do
                      (vim.diagnostic.config {:severity_sort true
                                              :virtual_text false}
                                             (vim.lsp.diagnostic.get_namespace client.id))
                      (let [filetype (vim.api.nvim_get_option_value :filetype
                                                                    {:buf bufnr})]
                        ; fennel has its own hybrid doc/definition mappings in ftplugin
                        (if (not= filetype :fennel)
                            (do
                              (vim.keymap.set :n :K
                                              #(vim.lsp.buf.hover {:border :double
                                                                   :focusable false})
                                              {:buffer bufnr
                                               :desc "LSP: Hover"
                                               :noremap true
                                               :silent true})
                              (vim.keymap.set :n :gd vim.lsp.buf.definition
                                              {:desc "Go to definition"
                                               :buffer bufnr}))))
                      (vim.keymap.set :n :<leader>gh
                                      #(vim.lsp.buf.signature_help {:border :double})
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
                                      {:buffer bufnr}) ; picker backend
                      (vim.keymap.set :n :<leader>ld picker.diagnostics
                                      {:buffer bufnr})
                      (vim.keymap.set :n :<leader>lr picker.references
                                      {:buffer bufnr}))))})

(fn lsp-format [bufnr]
  (vim.lsp.buf.format {:filter (fn [client]
                                 (or (= client.name :efm)
                                     (= client.name :efm_prettier)
                                     (= client.name :efm_oxfmt)))}))

(fn open-lsp-log [opts]
  (let [path (vim.lsp.log.get_filename)
        mods (or opts.mods "")]
    (if (or (= nil path) (= path ""))
        (vim.notify "No LSP log file is available" vim.log.levels.ERROR)
        (vim.cmd (.. mods (if (= mods "") "edit " " edit ")
                     (vim.fn.fnameescape path))))))

(fn open-lsp-info []
  (vim.cmd "checkhealth vim.lsp"))

(fn read-json-file [path]
  (if (= 1 (vim.fn.filereadable path))
      (let [result [(pcall vim.json.decode
                           (table.concat (vim.fn.readfile path) "\n"))]]
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
            s (string.gsub s :^v "")]
        s)
      nil))

(fn typescript-spec-uses-tsgo? [spec]
  (if spec
      (let [s (normalize-typescript-spec spec)
            direct-major (tonumber (string.match s "^[~^]?([0-9]+)"))
            gte-major (tonumber (string.match s ">=%s*([0-9]+)"))
            gt-major (tonumber (string.match s ">%s*([0-9]+)"))]
        (or (and direct-major (>= direct-major 7))
            (and gte-major (>= gte-major 7)) (and gt-major (>= gt-major 6))))
      false))

(fn package-dependency-spec [package-json dependency-key]
  (or (vim.tbl_get package-json dependency-key :typescript)
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
      (let [installed-typescript (or (read-json-file (.. dir
                                                         :/node_modules/typescript/package.json))
                                     (read-json-file (.. dir
                                                         "/node_modules/@typescript/native-preview/package.json")))
            installed-version (if installed-typescript
                                  (vim.tbl_get installed-typescript :version)
                                  nil)
            installed-major (parse-major-version installed-version)]
        (if installed-major
            (>= installed-major 7)
            (let [package-json (read-json-file (.. dir :/package.json))
                  declared-spec (package-typescript-spec package-json)]
              (typescript-spec-uses-tsgo? declared-spec))))
      false))

(fn project-uses-tsgo? [bufnr root]
  (let [package-root (vim.fs.root bufnr [:package.json])]
    (or (package-uses-tsgo? package-root) (package-uses-tsgo? root))))

(fn default-ts-root-dir [bufnr on-dir]
  (let [root-markers [:package-lock.json
                      :yarn.lock
                      :pnpm-lock.yaml
                      :bun.lockb
                      :bun.lock
                      :package.json]
        root-markers (if (= 1 (vim.fn.has :nvim-0.11.3))
                         [root-markers [:.git]]
                         (vim.list_extend root-markers [:.git]))]
    (if (vim.fs.root bufnr [:deno.json :deno.jsonc :deno.lock])
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
        (base-root-dir bufnr (fn [root]
                               (if (= use-tsgo? (project-uses-tsgo? bufnr root))
                                   (on-dir root)))))))

(fn conditional-eslint-root-dir [base-root-dir]
  (fn [bufnr on-dir]
    (if (project-uses-oxlint? bufnr)
        nil
        (if base-root-dir
            (base-root-dir bufnr on-dir)))))

(fn find-fennel-ls-project-config [path]
  (if (and path (not= path ""))
      (. (vim.fs.find [:flsproject.fnl]
                      {: path :upward true :type :file :limit 1}) 1)
      nil))

(fn fennel-ls-root-dir [bufnr on-dir]
  (let [fname (vim.api.nvim_buf_get_name bufnr)
        config-path (find-fennel-ls-project-config fname)
        git-root (vim.fs.root bufnr [:.git])
        fallback-root (if (not= fname "")
                          (vim.fs.dirname fname)
                          (vim.fn.getcwd))]
    (on-dir (or (and config-path (vim.fs.dirname config-path)) git-root
                fallback-root))))

(fn ensure-fennel-ls-fallback-config [root]
  (let [cache-dir (vim.fs.joinpath (vim.fn.stdpath :cache) :fennel-ls
                                   (vim.fn.sha256 root))
        config-path (vim.fs.joinpath cache-dir :flsproject.fnl)
        fennel-path (table.concat [(.. root :/?.fnl)
                                   (.. root :/?/init.fnl)
                                   (.. root :/src/?.fnl)
                                   (.. root :/src/?/init.fnl)]
                                  ";")
        macro-path (table.concat [(.. root :/?.fnl)
                                  (.. root :/?/init-macros.fnl)
                                  (.. root :/?/init.fnl)
                                  (.. root :/src/?.fnl)
                                  (.. root :/src/?/init-macros.fnl)
                                  (.. root :/src/?/init.fnl)]
                                 ";")
        lines [(.. "{:fennel-path " (vim.fn.json_encode fennel-path))
               (.. " :macro-path " (vim.fn.json_encode macro-path))
               " :extra-globals \"vim\"}"]]
    (vim.fn.mkdir cache-dir :p)
    (vim.fn.writefile lines config-path)
    cache-dir))

(fn start-fennel-ls [dispatchers config]
  (let [root-dir config.root_dir
        cwd (if (and root-dir (not (find-fennel-ls-project-config root-dir)))
                (ensure-fennel-ls-fallback-config root-dir)
                root-dir)]
    (set config.cmd_cwd cwd)
    (vim.lsp.rpc.start [:fennel-ls] dispatchers {: cwd})))

(fn _setup []
  (let [setup-args (make-setup-args)
        ts-base-root-dir (or (vim.tbl_get vim.lsp.config :tsgo :root_dir)
                             (vim.tbl_get vim.lsp.config :vtsls :root_dir)
                             default-ts-root-dir)
        eslint-base-root-dir (vim.tbl_get vim.lsp.config :eslint :root_dir)
        eslint-root-dir (conditional-eslint-root-dir eslint-base-root-dir)
        tsgo-root-dir (conditional-root-dir ts-base-root-dir true)
        vtsls-root-dir (conditional-root-dir ts-base-root-dir false)]
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
    (vim.lsp.config :fennel_ls
                    (vim.tbl_deep_extend :force setup-args
                                         {:cmd start-fennel-ls
                                          :root_dir fennel-ls-root-dir}))
    (vim.lsp.config :eslint {:root_dir eslint-root-dir})
    (vim.lsp.config :oxlint
                    (vim.tbl_deep_extend :force setup-args
                                         {:cmd [:oxlint :--lsp]
                                          :root_dir oxlint-root-dir})))
  (vim.lsp.enable [:bashls
                   :clangd
                   :eslint
                   :fennel_ls
                   :gopls
                   :lua_ls
                   :terraformls
                   :tsgo
                   :vtsls
                   :yamlls
                   :oxlint])
  (vim.api.nvim_create_user_command :LspLog open-lsp-log
                                    {:desc "Open LSP log" :nargs 0 :bar true})
  (vim.api.nvim_create_user_command :LspInfo open-lsp-info
                                    {:desc "Show LSP info" :nargs 0 :bar true})
  (vim.keymap.set :n :<leader>lf #(lsp-format 0))
  (vim.keymap.set :v :<leader>lf #(lsp-format 0))
  ;; replace neovim's built-in VimLeavePre handler. the built-in one sends
  ;; shutdown → SIGTERM, but eslint ignores SIGTERM and hangs the exit.
  ;; ours does: graceful shutdown → wait → SIGKILL.
  (let [autocmds (vim.api.nvim_get_autocmds {:event :VimLeavePre})]
    (each [_ ac (ipairs autocmds)]
      (when (= ac.desc "vim.lsp: exit handler")
        (vim.api.nvim_del_autocmd ac.id))))
  (vim.api.nvim_create_autocmd :VimLeavePre
                               {:desc "lsp: fast exit"
                                :callback (fn [] ; send graceful shutdown to all clients
                                            (each [_ client (ipairs (vim.lsp.get_clients))]
                                              (pcall #(client:stop)))
                                            ; wait up to 500ms for graceful exit
                                            (vim.wait 500
                                                      #(= (length (vim.lsp.get_clients))
                                                          0)
                                                      50)
                                            ; SIGKILL anything still alive
                                            (let [remaining (vim.lsp.get_clients)]
                                              (when (> (length remaining) 0)
                                                (let [transport (require :vim.lsp._transport)]
                                                  (set transport.TransportRun.terminate
                                                       (fn [self]
                                                         (when self.sysobj
                                                           (self.sysobj:kill 9)))))
                                                (each [_ client (ipairs remaining)]
                                                  (pcall #(client.rpc.terminate)))
                                                ; let event loop process the kills
                                                (vim.wait 100
                                                          #(= (length (vim.lsp.get_clients))
                                                              0)
                                                          25))))}))

(var is-loaded false)

(fn setup []
  (if (not is-loaded)
      (do
        (_setup)
        (set is-loaded true))))

{: setup : make-setup-args}
