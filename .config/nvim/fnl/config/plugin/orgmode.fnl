(module config.plugin.orgmode {autoload {orgmode orgmode}})

; Do i need more than this?
(orgmode.setup_ts_grammar)
(orgmode.setup {:org_agenda_files "~/code/notes/org/agenda/*"
                :org_default_notes_file "~/code/notes/org/notes.org"})
