(module config.plugin.hardtime {autoload {hardtime hardtime}})

(hardtime.setup {:disabled_filetypes [:checkhealth
                                      :fugitiveblame
                                      :help
                                      :netrw
                                      :NeogitStatus
                                      :notify
                                      :Outline
                                      :packer
                                      :prompt
                                      :qf
                                      :TelescopePrompt
                                      :terminal]})
