(local markview (require :markview))

(markview.setup {:preview {:modes [:n :no :v :i :c]
                           :filetypes [:markdown :Avante]
                           :hybrid_modes [:i :v]}})
