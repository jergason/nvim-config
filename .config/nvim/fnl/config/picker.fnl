(var extra nil)
(var pick nil)

(local backend-order [:fff :mini.pick])
(local default-backend :fff)

(local backend-ready {})
(var is-setup false)

(local nvim-config-dir (vim.fn.expand "~/.config/nvim"))
(local lazy-plugin-dir (vim.fn.expand "~/.local/share/nvim/lazy"))
(local root-markers [:.git
                     :package.json
                     :package-lock.json
                     :yarn.lock
                     :pnpm-lock.yaml
                     :bun.lock
                     :bun.lockb
                     :go.mod
                     :Cargo.toml
                     :pyproject.toml
                     :requirements.txt])

(local ignored-search-globs
       {:drplt [:local/** :config/user.json :!**/node_modules/**]})

(fn ensure-mini-modules []
  (if (= nil extra)
      (set extra (require :mini.extra)))
  (if (= nil pick)
      (set pick (require :mini.pick))))

(fn fallback-cwd []
  (let [name (vim.api.nvim_buf_get_name 0)]
    (if (not= name "")
        (vim.fs.dirname name)
        (vim.fn.getcwd))))

(fn resolve-cwd [cwd]
  (if cwd
      cwd
      (let [root (vim.fs.root (vim.api.nvim_get_current_buf) root-markers)]
        (if root
            root
            (fallback-cwd)))))

(fn resolve-git-root [cwd]
  (or (vim.fs.root (or cwd (vim.api.nvim_get_current_buf)) [:.git])
      (resolve-cwd cwd)))

(fn ignored-search-config [cwd]
  (let [root (resolve-git-root cwd)
        project-name (if root
                         (vim.fn.fnamemodify root ":t")
                         nil)
        globs (if project-name
                  (. ignored-search-globs project-name)
                  nil)]
    (if globs
        {:cwd root : globs}
        nil)))

(fn backend-valid? [backend]
  (vim.tbl_contains backend-order backend))

(fn current-backend []
  (let [backend (or vim.g.picker_backend default-backend)]
    (if (backend-valid? backend)
        backend
        default-backend)))

(fn mini-send-to-quickfix []
  (let [matches (pick.get_picker_matches)]
    (if (or (= nil matches) (= nil matches.all))
        nil
        (let [items (if (and matches.marked (> (length matches.marked) 0))
                        matches.marked
                        matches.all)]
          (pick.default_choose_marked items {:list_type :quickfix})
          true))))

(fn setup-mini []
  (ensure-mini-modules)
  (pick.setup {:window {:prompt_prefix " "}
               :mappings {:send_to_quickfix {:char :<C-q>
                                             :func mini-send-to-quickfix}}})
  (extra.setup {}))

(fn setup-fff []
  (let [result [(pcall require :fff)]
        ok (. result 1)
        err (. result 2)]
    (if (not ok)
        (error err))))

(local backend-setups {:mini.pick setup-mini :fff setup-fff})

(fn ensure-backend [backend]
  (if (not (. backend-ready backend))
      (let [setup-fn (. backend-setups backend)]
        (if setup-fn
            (do
              (setup-fn)
              (tset backend-ready backend true))
            (error (.. "Unknown picker backend: " backend))))))

(fn run-with-backend [handlers]
  (let [backend (current-backend)
        handler (. handlers backend)]
    (if (= nil handler)
        (vim.notify (.. "No handler for picker backend: " backend)
                    vim.log.levels.ERROR)
        (let [result [(pcall #(ensure-backend backend))]
              ok (. result 1)
              err (. result 2)]
          (if (not ok)
              (vim.notify err vim.log.levels.ERROR)
              (handler))))))

(fn mini-files-command [query]
  [:fd
   :--type
   :f
   :--hidden
   :--exclude
   :.git
   :--color=never
   :--fixed-strings
   query])

(fn ignored-files-command [globs]
  (let [command [:rg :--files :--hidden :--no-ignore]]
    (each [_ glob (ipairs (or globs []))]
      (table.insert command :--glob)
      (table.insert command glob))
    command))

(fn mini-files-name [globs]
  (if (> (length globs) 0)
      (.. "Files (" (table.concat globs ", ") ")")
      :Files))

(fn mini-grep-name [globs]
  (if (> (length globs) 0)
      (.. "Grep live (rg | " (table.concat globs ", ") ")")
      "Grep live (rg)"))

(fn mini-grep-command [pattern globs opts]
  (let [command [:rg
                 :--column
                 :--line-number
                 :--no-heading
                 :--field-match-separator
                 "\000"
                 :--color=never
                 :--hidden
                 :--smart-case]]
    (if (. (or opts {}) :no-ignore)
        (table.insert command :--no-ignore))
    (each [_ glob (ipairs (or globs []))]
      (table.insert command :--glob)
      (table.insert command glob))
    (table.insert command "--")
    (table.insert command pattern)
    command))

(fn mini-files [cwd]
  (local set-items-opts {:do_match false :querytick (pick.get_querytick)})
  (local spawn-opts {: cwd})
  (var sys {:kill (fn [] nil)})
  (local source-match
         (fn [_ _ query]
           ((. sys :kill))
           (if (= (pick.get_querytick) (. set-items-opts :querytick))
               nil
               (if (= (length query) 0)
                   (do
                     (set sys {:kill (fn [] nil)})
                     (pick.set_picker_items [] set-items-opts))
                   (do
                     (tset set-items-opts :querytick (pick.get_querytick))
                     (set sys
                          (pick.set_picker_items_from_cli (mini-files-command (table.concat query
                                                                                            ""))
                                                          {:set_items_opts set-items-opts
                                                           :spawn_opts spawn-opts})))))))
  (pick.start {:source {:name "Files (fd query)"
                        : cwd
                        :items []
                        :match source-match}}))

(fn mini-files-ignored [cwd globs]
  (let [task (vim.system (ignored-files-command globs) {: cwd :text true})
        result (task:wait)
        code (. result :code)]
    (if (> code 1)
        (vim.notify (or (. result :stderr) "Failed to list ignored files.")
                    vim.log.levels.ERROR)
        (pick.start {:source {:name (mini-files-name globs)
                              : cwd
                              :items (vim.split (or (. result :stdout) "") "\n"
                                                {:trimempty true})}}))))

(fn mini-grep-live [cwd globs opts]
  (local globs (vim.deepcopy (or globs [])))
  (local opts (or opts {}))
  (local set-items-opts {:do_match false :querytick (pick.get_querytick)})
  (local spawn-opts {: cwd})
  (var sys {:kill (fn [] nil)})
  (local source-match
         (fn [_ _ query]
           ((. sys :kill))
           (if (= (pick.get_querytick) (. set-items-opts :querytick))
               nil
               (if (= (length query) 0)
                   (do
                     (set sys {:kill (fn [] nil)})
                     (pick.set_picker_items [] set-items-opts))
                   (do
                     (tset set-items-opts :querytick (pick.get_querytick))
                     (set sys
                          (pick.set_picker_items_from_cli (mini-grep-command (table.concat query
                                                                                           "")
                                                                             globs
                                                                             opts)
                                                          {:set_items_opts set-items-opts
                                                           :spawn_opts spawn-opts})))))))
  (local add-glob
         (fn []
           (vim.ui.input {:prompt "Glob pattern: "}
                         (fn [glob]
                           (if (and glob (not= glob ""))
                               (do
                                 (table.insert globs glob)
                                 (pick.set_picker_opts {:source {:name (mini-grep-name globs)}})
                                 (pick.set_picker_query (pick.get_picker_query))))))))
  (pick.start {:source {:name (mini-grep-name globs)
                        : cwd
                        :items []
                        :match source-match}
               :mappings {:add_glob {:char :<C-o> :func add-glob}}}))

(fn mini-grep-word [cwd]
  (pick.builtin.cli {:command (mini-grep-command (vim.fn.expand :<cword>) [])}
                    {:source {:name "Grep word (rg)" : cwd}}))

(fn find-files [opts]
  (let [opts (or opts {})
        cwd (. opts :cwd)
        mini-cwd (resolve-cwd cwd)]
    (run-with-backend {:mini.pick (fn []
                                    (mini-files mini-cwd))
                       :fff (fn []
                              (local fff (require :fff))
                              (if cwd
                                  (fff.find_files_in_dir cwd)
                                  (fff.find_files)))})))

(fn grep [opts]
  (let [opts (or opts {})
        cwd (. opts :cwd)
        mini-cwd (resolve-cwd cwd)]
    (run-with-backend {:mini.pick (fn []
                                    (mini-grep-live mini-cwd []))
                       :fff (fn []
                              (local fff (require :fff))
                              (if cwd
                                  (fff.live_grep {: cwd})
                                  (fff.live_grep)))})))

(fn grep-ignored []
  (let [config (ignored-search-config nil)]
    (if (= nil config)
        (vim.notify "No ignored search globs configured for this project."
                    vim.log.levels.WARN)
        (mini-grep-live (. config :cwd)
                        (. config :globs)
                        {:no-ignore true}))))

(fn find-ignored []
  (let [config (ignored-search-config nil)]
    (if (= nil config)
        (vim.notify "No ignored search globs configured for this project."
                    vim.log.levels.WARN)
        (mini-files-ignored (. config :cwd) (. config :globs)))))

(fn grep-word []
  (let [mini-cwd (resolve-cwd nil)]
    (run-with-backend {:mini.pick (fn []
                                    (mini-grep-word mini-cwd))
                       :fff (fn []
                              (local fff (require :fff))
                              (local query (vim.fn.expand :<cword>))
                              (if (= query "")
                                  (fff.live_grep)
                                  (fff.live_grep {: query})))})))

(fn buffers []
  (pick.builtin.buffers))

(fn help-tags []
  (pick.builtin.help))

(fn diagnostics []
  (extra.pickers.diagnostic))

(fn commands []
  (extra.pickers.commands))

(fn history []
  (extra.pickers.history {:scope ":"}))

(fn buffer-fuzzy-find []
  (extra.pickers.buf_lines {:scope :current}))

(fn references []
  (extra.pickers.lsp {:scope :references}))

(fn grep-in-glob []
  (let [mini-cwd (resolve-cwd nil)]
    (run-with-backend {:mini.pick (fn []
                                    (vim.ui.input {:prompt "Enter a glob: "
                                                   :default "*"}
                                                  (fn [glob]
                                                    (if (and glob
                                                             (not= glob ""))
                                                        (mini-grep-live mini-cwd
                                                                        [glob])))))
                       :fff (fn []
                              (vim.ui.input {:prompt "Enter a glob: "
                                             :default "*"}
                                            (fn [glob]
                                              (if (and glob (not= glob ""))
                                                  (let [fff (require :fff)]
                                                    (fff.live_grep {:query (.. glob
                                                                               " ")}))))))})))

(fn escape-substitute [input]
  (vim.fn.escape input "\\/&"))

(fn quickfix-replace []
  (let [qf-size (. (vim.fn.getqflist {:size 0}) :size)]
    (if (= qf-size 0)
        (vim.notify "Quickfix is empty. Use <C-q> in a picker first."
                    vim.log.levels.WARN)
        (vim.ui.input {:prompt "Find pattern: "
                       :default (vim.fn.expand :<cword>)}
                      (fn [find]
                        (if (and find (not= find ""))
                            (vim.ui.input {:prompt "Replace with: "}
                                          (fn [replace]
                                            (if (not= nil replace)
                                                (let [lhs (escape-substitute find)
                                                      rhs (escape-substitute replace)
                                                      cmd (.. "cfdo %s/" lhs
                                                              "/" rhs
                                                              "/gce | update")
                                                      result [(pcall #(vim.cmd cmd))]
                                                      ok (. result 1)
                                                      err (. result 2)]
                                                  (if ok
                                                      (vim.cmd :copen)
                                                      (vim.notify err
                                                                  vim.log.levels.ERROR))))))))))))

(fn set-backend [backend]
  (if (backend-valid? backend)
      (do
        (set vim.g.picker_backend backend)
        (vim.notify (.. "Picker backend: " backend))
        true)
      (do
        (vim.notify (.. "Invalid picker backend: " backend ". Choose one of: "
                        (table.concat backend-order ", "))
                    vim.log.levels.ERROR)
        false)))

(fn cycle-backend []
  (let [backend (current-backend)
        idx (vim.fn.index backend-order backend)
        next-idx (% (+ idx 1) (length backend-order))
        next-backend (. backend-order (+ next-idx 1))]
    (set-backend next-backend)))

(fn choose-backend []
  (vim.ui.select backend-order {:prompt "Choose picker backend"}
                 (fn [choice]
                   (if choice
                       (set-backend choice)))))

(fn set-keymaps []
  (vim.keymap.set :n :<leader>ff find-files {:desc "Find files"})
  (vim.keymap.set :n :<leader>fg grep {:desc "Live grep"})
  (vim.keymap.set :n :<leader>fF find-ignored
                  {:desc "Find ignored allowlist files"})
  (vim.keymap.set :n :<leader>fb buffers {:desc "Find open buffers"})
  (vim.keymap.set :n :<leader>fh help-tags {:desc "Help tags"})
  (vim.keymap.set :n :<leader>fw grep-word {:desc "Find word under cursor"})
  (vim.keymap.set :n :<leader>fI grep-ignored
                  {:desc "Live grep ignored allowlist"})
  (vim.keymap.set :n :<leader>fd diagnostics {:desc "Project diagnostics"})
  (vim.keymap.set :n :<leader>fc commands {:desc :Commands})
  (vim.keymap.set :n :<leader>th history {:desc "Command history"})
  (vim.keymap.set :n :<C-/> buffer-fuzzy-find
                  {:desc "Fuzzy find in current buffer"})
  (vim.keymap.set :n :<C-_> buffer-fuzzy-find
                  {:desc "Fuzzy find in current buffer"})
  (vim.keymap.set :n :<leader>flg grep-in-glob
                  {:desc "Live grep in files matching a glob"})
  (vim.keymap.set :n :<leader>fn #(find-files {:cwd nvim-config-dir})
                  {:desc "Edit neovim config"})
  (vim.keymap.set :n :<leader>fp #(find-files {:cwd lazy-plugin-dir})
                  {:desc "Search plugin files"})
  (vim.keymap.set :n :<leader>fr quickfix-replace
                  {:desc "Replace across current quickfix list"})
  (vim.keymap.set :n :<leader>fP choose-backend {:desc "Choose picker backend"}))

(fn set-commands []
  (vim.api.nvim_create_user_command :PickerBackend
                                    (fn [opts]
                                      (if (= opts.args "")
                                          (vim.notify (.. "Picker backend: "
                                                          (current-backend)))
                                          (set-backend opts.args)))
                                    {:nargs "?"
                                     :complete (fn [_ _ _]
                                                 backend-order)})
  (vim.api.nvim_create_user_command :PickerBackendCycle cycle-backend {})
  (vim.api.nvim_create_user_command :PickerFindIgnored find-ignored {})
  (vim.api.nvim_create_user_command :PickerGrepIgnored grep-ignored {})
  (vim.api.nvim_create_user_command :QfReplace quickfix-replace {}))

(fn setup []
  (if (not is-setup)
      (do
        (if (not (backend-valid? vim.g.picker_backend))
            (set vim.g.picker_backend default-backend))
        (ensure-backend :mini.pick)
        (set-keymaps)
        (set-commands)
        (set is-setup true))))

{: setup
 : diagnostics
 : references
 : find-files
 : find-ignored
 : grep
 : grep-ignored
 : grep-word
 : grep-in-glob
 : quickfix-replace
 : set-backend
 : current-backend}
