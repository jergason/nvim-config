(fn large? [buf]
  (let [lines (vim.api.nvim_buf_line_count buf)
        bytes (vim.api.nvim_buf_get_offset buf lines)]
    (or (>= lines 30000) (>= bytes (* 512 1024)))))

{: large?}
