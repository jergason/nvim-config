(local api (require :nfnl.api))

;; Match save-time orphan detection: search from the buffer, not the cwd.
;; Keep explicit directories, including those passed by nfnl's save hook.
(each [_ name (ipairs [:find-orphans :delete-orphans])]
  (let [operation (. api name)]
    (tset api name
          (fn [opts]
            (operation (vim.tbl_extend :keep opts
                                       {:dir (vim.fn.expand "%:p:h")}))))))
