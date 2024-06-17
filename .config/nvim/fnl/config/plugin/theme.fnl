(module config.plugin.theme {autoload {theme github-theme nvim aniseed.nvim}})

(theme.setup {:options {:styles {:comments :italic} :darken {:float true}}})

(nvim.ex.colorscheme :tokyonight-moon)

