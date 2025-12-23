(local theme (require :github-theme))

(theme.setup {:options {:styles {:comments :italic} :darken {:float true}}})

(vim.cmd "colorscheme tokyonight")
