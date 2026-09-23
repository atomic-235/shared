" Logical English 2 (.le) syntax highlighting.
" Sections, % comments, *placeholders*, "strings", connectors.

if exists('b:current_syntax')
  finish
endif

syn case ignore

" % comment to end of line
syn match leComment "%.\{-}$" contains=@Spell

" section headers
syn match leHeader "^\s*the templates are:"
syn match leHeader "^\s*the \(constants\|functions\|fluents\|events\|actions\|predicates\|queries\|templates\|ontology\|resources\) are:"
syn match leHeader "^\s*the knowledge base\s\+.*\s\+\(includes\|extends\)\%( these resources\)\?:"
syn match leHeader "^\s*scenario\s\+.*\s\+is:"
syn match leHeader "^\s*query\s\+.*\s\+is:"

" sentence words worth spotting; trim or extend to taste
syn keyword leKeyword if then and or not otherwise where when which who that
syn keyword leKeyword for all each every expects answers

" *a person* style template placeholders
syn match lePlaceholder "\*[^*\n]\+\*"

syn region leString start=+"+ end=+"+
syn match leNumber "\<\d\+\%(\.\d\+\)\?\>"

highlight default link leComment Comment
highlight default link leHeader Statement
highlight default link leKeyword Keyword
highlight default link lePlaceholder Special
highlight default link leString String
highlight default link leNumber Number

let b:current_syntax = 'le'
