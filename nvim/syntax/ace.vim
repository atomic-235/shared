" Attempto Controlled English (.ace) — the carwash-style texts beside
" logical_english's ace command. Highlighting stays structural: comments and
" the query marker; the words themselves are colored by the lexicon through
" ace-lsp's semantic tokens (ape's -csyntaxd classes: noun/verb/adjective/...).
" These are `hi def link` defaults — a colorscheme overrides them.
syn region aceComment start="^\s*#" end="$" contains=aceQuery
syn region aceBlockComment start="/\*" end="\*/" contains=aceQuery
syn match aceQuery contained "#\s*query\s*:" nextgroup=aceQueryString
syn region aceQueryString start=":\s*" end="$" contained

hi def link aceComment Comment
hi def link aceBlockComment Comment
hi def link aceQuery Special
hi def link aceQueryString Title

" ace-lsp semantic tokens (token types from the legend in lsp/ace/server.ts):
" the lexicon classes of each word.
hi def link @lsp.type.noun        Identifier
hi def link @lsp.type.verb        Function
hi def link @lsp.type.adjective   Type
hi def link @lsp.type.adverb      Special
hi def link @lsp.type.preposition PreProc
hi def link @lsp.type.properName  Constant
hi def link @lsp.type.variable    Identifier
hi def link @lsp.type.keyword     Statement
hi def link @lsp.type.string      String