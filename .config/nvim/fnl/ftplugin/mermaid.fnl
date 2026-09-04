(local mappings [[:<leader>mp
                  :<cmd>MermaidPreview<cr>
                  "Preview Mermaid diagram"]
                 [:<leader>mf :<cmd>MermaidFormat<cr> "Format Mermaid diagram"]
                 [:<leader>mr
                  :<cmd>MermaidRender<cr>
                  "Render Mermaid diagram in terminal"]
                 [:<leader>mc
                  :<cmd>MermaidCopyURL<cr>
                  "Copy Mermaid preview URL"]
                 [:<leader>mx
                  :<cmd>MermaidPreviewStop<cr>
                  "Stop Mermaid preview"]])

(each [_ [lhs rhs desc] (ipairs mappings)]
  (vim.keymap.set :n lhs rhs {:buffer 0 : desc}))
