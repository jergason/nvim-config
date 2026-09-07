(fn report-error [message]
  (vim.notify (.. "PR diff: " message) vim.log.levels.ERROR))

(fn run [cwd command next-step]
  (let [(ok err) (pcall vim.system command {: cwd :text true
                                          :env {:GIT_TERMINAL_PROMPT "0"}}
                        (vim.schedule_wrap
                          (fn [result]
                            (if (= result.code 0)
                                (next-step result.stdout)
                                (report-error (vim.trim result.stderr))))))]
    (when (not ok) (report-error err))))

(fn open-pr-diff []
  (let [cwd (or (vim.fs.root 0 [:.git]) (vim.fn.getcwd))]
    (run cwd [:gh :pr :view :--json "baseRefName,baseRefOid,url"]
         (fn [output]
           (let [(ok pr) (pcall vim.json.decode output)]
             (if (not ok)
                 (report-error "Could not read the GitHub PR response")
                 (let [repository (pr.url:match "^(https://.+)/pull/%d+$")]
                   (if (not repository)
                       (report-error "Could not determine the PR repository")
                       (do
                         (vim.notify (.. "PR diff: fetching target " pr.baseRefName))
                         ; Fetch from the base repository, which may differ from origin for forks.
                         ; Use the returned commit directly, without shared FETCH_HEAD state.
                         (run cwd [:git :-c "credential.helper="
                                   :-c "credential.helper=!gh auth git-credential"
                                   :fetch :--no-tags :--no-write-fetch-head
                                   (.. repository ".git") pr.baseRefOid]
                              (fn [_]
                                ((. (require :diffview) :open)
                                 [(.. pr.baseRefOid "...HEAD")
                                  :--imply-local (.. "-C" cwd)]))))))))))))

(vim.api.nvim_create_user_command :DiffviewPR open-pr-diff
                                  {:desc "Diff current PR against its GitHub target"})
(vim.keymap.set :n :<leader>gp open-pr-diff
                {:desc "Git: review current PR diff"})
