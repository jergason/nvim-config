(local backend-order [:fzf-lua :mini.pick :snacks :fff])
(local default-backend :fff)
(local fallback-backend :mini.pick)

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

(fn backend-valid? [backend]
  (vim.tbl_contains backend-order backend))

(fn current-backend []
  (let [backend (or vim.g.picker_backend default-backend)]
    (if (backend-valid? backend)
        backend
        default-backend)))

(fn mini-send-to-quickfix []
  (let [pick (require :mini.pick)
        matches (pick.get_picker_matches)]
    (if (or (= nil matches) (= nil matches.all))
        nil
        (let [items (if (and matches.marked (> (length matches.marked) 0))
                        matches.marked
                        matches.all)]
          (pick.default_choose_marked items {:list_type :quickfix})
          true))))

(fn setup-fzf-lua []
  (let [fzf (require :fzf-lua)
        fzf-actions (require :fzf-lua.actions)]
    (fzf.setup {:defaults {:copen "botright copen"}
                :files {:rg_opts "--color=never --files"}
                :grep {:rg_opts "--column --line-number --no-heading --color=always --smart-case --max-columns=4096 -e"}
                :actions {:files {1 true :ctrl-q fzf-actions.file_sel_to_qf}}})))

(fn setup-mini []
  (let [pick (require :mini.pick)
        extra (require :mini.extra)]
    (pick.setup {:window {:prompt_prefix " "}
                 :mappings {:send_to_quickfix {:char :<C-q>
                                               :func mini-send-to-quickfix}}})
    (extra.setup {})))

(fn setup-snacks []
  (let [snacks (require :snacks)]
    (snacks.setup {:picker {:enabled true}})))

(fn setup-fff []
  (let [result [(pcall require :fff)]
        ok (. result 1)
        err (. result 2)]
    (if (not ok)
        (error err))))

(local backend-setups {:fzf-lua setup-fzf-lua
                       :mini.pick setup-mini
                       :snacks setup-snacks
                       :fff setup-fff})

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

(fn mini-grep-name [globs]
  (if (> (length globs) 0)
      (.. "Grep live (rg | " (table.concat globs ", ") ")")
      "Grep live (rg)"))

(fn mini-grep-command [pattern globs]
  (let [command [:rg
                 :--column
                 :--line-number
                 :--no-heading
                 :--field-match-separator
                 "\000"
                 :--color=never
                 :--hidden
                 :--smart-case]]
    (each [_ glob (ipairs (or globs []))]
      (table.insert command :--glob)
      (table.insert command glob))
    (table.insert command "--")
    (table.insert command pattern)
    command))

(fn mini-files [cwd]
  (local pick (require :mini.pick))
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

(fn mini-grep-live [cwd globs]
  (local pick (require :mini.pick))
  (local globs (vim.deepcopy (or globs [])))
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
                                                                             globs)
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
  (let [pick (require :mini.pick)]
    (pick.builtin.cli {:command (mini-grep-command (vim.fn.expand :<cword>) [])}
                      {:source {:name "Grep word (rg)" : cwd}})))

(fn find-files [opts]
  (let [opts (or opts {})
        cwd (. opts :cwd)
        mini-cwd (resolve-cwd cwd)]
    (run-with-backend {:fzf-lua (fn []
                                  (local fzf (require :fzf-lua))
                                  (fzf.files {: cwd}))
                       :mini.pick (fn []
                                    (mini-files mini-cwd))
                       :snacks (fn []
                                 (local snacks (require :snacks))
                                 (snacks.picker.files {: cwd :hidden true}))
                       :fff (fn []
                              (local fff (require :fff))
                              (if cwd
                                  (fff.find_files_in_dir cwd)
                                  (fff.find_files)))})))

(fn grep [opts]
  (let [opts (or opts {})
        cwd (. opts :cwd)
        mini-cwd (resolve-cwd cwd)]
    (run-with-backend {:fzf-lua (fn []
                                  (local fzf (require :fzf-lua))
                                  (fzf.live_grep {: cwd}))
                       :mini.pick (fn []
                                    (mini-grep-live mini-cwd []))
                       :snacks (fn []
                                 (local snacks (require :snacks))
                                 (snacks.picker.grep {: cwd}))
                       :fff (fn []
                              (local fff (require :fff))
                              (if cwd
                                  (fff.live_grep {: cwd})
                                  (fff.live_grep)))})))

(fn grep-word []
  (let [mini-cwd (resolve-cwd nil)]
    (run-with-backend {:fzf-lua (fn []
                                  (local fzf (require :fzf-lua))
                                  (fzf.grep_cword))
                       :mini.pick (fn []
                                    (mini-grep-word mini-cwd))
                       :snacks (fn []
                                 (local snacks (require :snacks))
                                 (snacks.picker.grep_word))
                       :fff (fn []
                              (local fff (require :fff))
                              (local query (vim.fn.expand :<cword>))
                              (if (= query "")
                                  (fff.live_grep)
                                  (fff.live_grep {: query})))})))

(fn buffers []
  (run-with-backend {:fzf-lua (fn []
                                (local fzf (require :fzf-lua))
                                (fzf.buffers))
                     :mini.pick (fn []
                                  (local pick (require :mini.pick))
                                  (pick.builtin.buffers))
                     :snacks (fn []
                               (local snacks (require :snacks))
                               (snacks.picker.buffers))
                     :fff (fn []
                            (local pick (require :mini.pick))
                            (pick.builtin.buffers))}))

(fn help-tags []
  (run-with-backend {:fzf-lua (fn []
                                (local fzf (require :fzf-lua))
                                (fzf.helptags))
                     :mini.pick (fn []
                                  (local pick (require :mini.pick))
                                  (pick.builtin.help))
                     :snacks (fn []
                               (local snacks (require :snacks))
                               (snacks.picker.help))
                     :fff (fn []
                            (local pick (require :mini.pick))
                            (pick.builtin.help))}))

(fn diagnostics []
  (run-with-backend {:fzf-lua (fn []
                                (local fzf (require :fzf-lua))
                                (fzf.diagnostics_workspace))
                     :mini.pick (fn []
                                  (local extra (require :mini.extra))
                                  (extra.pickers.diagnostic))
                     :snacks (fn []
                               (local snacks (require :snacks))
                               (snacks.picker.diagnostics))
                     :fff (fn [] ; fff doesn't support diagnostics so fall back to mini.extra
                            (local extra (require :mini.extra))
                            (extra.pickers.diagnostic))}))

(fn commands []
  (run-with-backend {:fzf-lua (fn []
                                (local fzf (require :fzf-lua))
                                (fzf.commands))
                     :mini.pick (fn []
                                  (local extra (require :mini.extra))
                                  (extra.pickers.commands))
                     :snacks (fn []
                               (local snacks (require :snacks))
                               (snacks.picker.commands))
                     :fff (fn []
                            (local extra (require :mini.extra))
                            (extra.pickers.commands))}))

(fn history []
  (run-with-backend {:fzf-lua (fn []
                                (local fzf (require :fzf-lua))
                                (fzf.history))
                     :mini.pick (fn []
                                  (local extra (require :mini.extra))
                                  (extra.pickers.history {:scope ":"}))
                     :snacks (fn []
                               (local snacks (require :snacks))
                               (snacks.picker.command_history))
                     :fff (fn []
                            (local extra (require :mini.extra))
                            (extra.pickers.history {:scope ":"}))}))

(fn buffer-fuzzy-find []
  (run-with-backend {:fzf-lua (fn []
                                (local fzf (require :fzf-lua))
                                (fzf.blines))
                     :mini.pick (fn []
                                  (local extra (require :mini.extra))
                                  (extra.pickers.buf_lines {:scope :current}))
                     :snacks (fn []
                               (local snacks (require :snacks))
                               (snacks.picker.lines))
                     :fff (fn []
                            (local extra (require :mini.extra))
                            (extra.pickers.buf_lines {:scope :current}))}))

(fn references []
  (run-with-backend {:fzf-lua (fn []
                                (local fzf (require :fzf-lua))
                                (fzf.lsp_references))
                     :mini.pick (fn []
                                  (local extra (require :mini.extra))
                                  (extra.pickers.lsp {:scope :references}))
                     :snacks (fn []
                               (local snacks (require :snacks))
                               (snacks.picker.lsp_references))
                     :fff (fn []
                            (local extra (require :mini.extra))
                            (extra.pickers.lsp {:scope :references}))}))

(fn grep-in-glob []
  (let [mini-cwd (resolve-cwd nil)]
    (run-with-backend {:fzf-lua (fn []
                                  (local fzf (require :fzf-lua))
                                  (fzf.live_grep_glob))
                       :mini.pick (fn []
                                    (vim.ui.input {:prompt "Enter a glob: "
                                                   :default "*"}
                                                  (fn [glob]
                                                    (if (and glob
                                                             (not= glob ""))
                                                        (mini-grep-live mini-cwd
                                                                        [glob])))))
                       :snacks (fn []
                                 (vim.ui.input {:prompt "Enter a glob: "
                                                :default "*"}
                                               (fn [glob]
                                                 (if (and glob (not= glob ""))
                                                     (let [snacks (require :snacks)]
                                                       (snacks.picker.grep {: glob}))))))
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
  (vim.keymap.set :n :<leader>fb buffers {:desc "Find open buffers"})
  (vim.keymap.set :n :<leader>fh help-tags {:desc "Help tags"})
  (vim.keymap.set :n :<leader>fw grep-word {:desc "Find word under cursor"})
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
  (vim.api.nvim_create_user_command :QfReplace quickfix-replace {}))

(fn setup []
  (if (not is-setup)
      (do
        (if (not (backend-valid? vim.g.picker_backend))
            (set vim.g.picker_backend default-backend))
        (set-keymaps)
        (set-commands)
        (set is-setup true))))

{: setup
 : diagnostics
 : references
 : find-files
 : grep
 : grep-word
 : grep-in-glob
 : quickfix-replace
 : set-backend
 : current-backend}
