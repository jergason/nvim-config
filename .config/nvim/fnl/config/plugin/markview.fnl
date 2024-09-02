(module config.plugin.markview {autoload {markview markview}})

(markview.setup {:modes [:n :no :v :i :c]
                 :hybrid_modes [:i :v]
                 :filetypes [:markdown :Avante]})

