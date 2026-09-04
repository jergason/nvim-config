(fn preload-patched-module [module-name runtime-file patch]
  (let [module-path (. (vim.api.nvim_get_runtime_file runtime-file true) 1)
        source (table.concat (vim.fn.readfile module-path) "\n")
        patched-source (patch source)]
    (tset package.preload module-name
          (assert (loadstring patched-source (.. "@" module-path))))))

(fn patch-loopback-preview-server [source]
  ;; mermaid.nvim currently binds its unauthenticated preview server to 0.0.0.0.
  ;; Keep the server local until upstream makes the host configurable.
  (let [bind-pattern "M%.server:bind%(\"0%.0%.0%.0\", port_to_bind%)"]
    (assert (string.find source bind-pattern)
            "mermaid.nvim preview bind changed; review the loopback patch")
    (string.gsub source bind-pattern
                 "M.server:bind(\"127.0.0.1\", port_to_bind)"
                 1)))

(fn patch-main-loop-lint [source]
  ;; parse_mmdc_error runs in a libuv callback. Resolve vim.diagnostic while
  ;; this module loads on the main loop, not later in the fast event.
  (let [severity-pattern "vim%.diagnostic%.severity"
        namespace-pattern
        "local namespace = vim%.api%.nvim_create_namespace%(\"mermaid_lint\"%)"]
    (assert (string.find source severity-pattern)
            "mermaid.nvim lint severity handling changed; review the fast-event patch")
    (assert (string.find source namespace-pattern)
            "mermaid.nvim lint namespace changed; review the fast-event patch")
    (let [pure-parser-source (string.gsub source severity-pattern
                                          "diagnostic_severity")]
      (string.gsub pure-parser-source namespace-pattern
                   (.. "local namespace = "
                       "vim.api.nvim_create_namespace(\"mermaid_lint\")\n"
                       "local diagnostic_severity = vim.diagnostic.severity")
                   1))))

(preload-patched-module :mermaid.server
                        :lua/mermaid/server.lua
                        patch-loopback-preview-server)
(preload-patched-module :mermaid.lint
                        :lua/mermaid/lint.lua
                        patch-main-loop-lint)

(local mermaid (require :mermaid))

(mermaid.setup {:format {:shift_width 4}
                :lint {:command :mmdc :enabled true}
                :preview {:renderer :mermaid.js :theme :dark}})
