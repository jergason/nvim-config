(module config.plugin.lualine
        {autoload {core aniseed.core
                   lualine lualine
                   lsp config.plugin.lspconfig}})

(defn lsp_connection
  []
  (if (vim.tbl_isempty (vim.lsp.get_clients {:bufnr 0}))
      ["LSP ❌"]
      ["LSP ✅" :lsp_status]))

(lualine.setup {:options {:theme :tokyonight
                          :icons_enabled true
                          :section_separators {:left "" :right ""}
                          :component_separators {:left "" :right ""}}
                :sections {:lualine_a [:mode {:upper true}]
                           :lualine_b [[:FugitiveHead]
                                       {1 :filename
                                        :file_status true
                                        :path 1
                                        :shorting_target 40}]
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
