(module config.plugin.markview {autoload {markview markview}})

(markview.setup {:preview {:modes [:n :no :v :i :c]
                           :filetypes [:markdown :Avante]
                           :hybrid_modes [:i :v]}})

