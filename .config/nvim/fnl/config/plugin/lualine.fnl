(local lualine (require :lualine))

(fn lsp_connection []
  (if (vim.tbl_isempty (vim.lsp.get_clients {:bufnr 0}))
      ["LSP ❌"]
      ["LSP ✅" :lsp_status]))

(lualine.setup {:options {:theme :tokyonight
                          :icons_enabled true
                          :section_separators {:left "" :right ""}
                          :component_separators {:left "" :right ""}}
                :sections {:lualine_a [:mode {:upper true}]
                           :lualine_b [{1 :filename
                                        :file_status true
                                        :path 1
                                        :shorting_target 40}
                                       {1 :FugitiveHead
                                        :fmt #(if (> (length $1) 220)
                                                  (.. (string.sub $1 1 17)
                                                      "…")
                                                  $1)}]
                           :lualine_c [{1 :buffers
                                        :mode 3
                                        :max_length 40
                                        :hide_filename_extension true}]
                           :lualine_x []
                           :lualine_y [{1 :diagnostics
                                        :sections [:error :warn :info :hint]
                                        :sources [:nvim_lsp]}
                                       (lsp_connection)
                                       :progress
                                       :location
                                       :filetype]
                           :lualine_z [:encoding]}
                :inactive_sections {:lualine_a []
                                    :lualine_b []
                                    :lualine_c [{1 :filename
                                                 :file_status true
                                                 :path 1}]
                                    :lualine_x []
                                    :lualine_y []
                                    :lualine_z []}})
