;; the highlighter recurses once per delimiter nesting level, so deeply
;; nested buffers (minified js, giant bundles) blow the lua stack.
;; returning nil from the strategy fn disables the plugin for that buffer.
(local max-lines 5000)
(local max-bytes (* 512 1024))

(fn pick-strategy [bufnr]
  (let [lines (vim.api.nvim_buf_line_count bufnr)
        bytes (vim.api.nvim_buf_get_offset bufnr lines)]
    (when (and (< lines max-lines) (< bytes max-bytes))
      :rainbow-delimiters.strategy.global)))

(set vim.g.rainbow_delimiters {:strategy {"" pick-strategy}})
