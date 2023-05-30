syntax match MavenLogInfo '^\[INFO\]'
syntax match MavenLogWarn '^\[WARN\]'
syntax match MavenLogError '^\[ERROR\]'

hi def link MavenLogInfo DiagnosticInfo
hi def link MavenLogWarn DiagnosticWarn
hi def link MavenLogError DiagnosticError
