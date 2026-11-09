" Quint (.qnt) syntax highlighting.
" Based on editor-plugins/vim/quint.vim from informalsystems/quint:
" https://github.com/quint-co/quint/blob/main/editor-plugins/vim/quint.vim

if exists("b:current_syntax")
  finish
endif

" operators and delimiters first: later matches win at the same position, so
" comments, numbers, and strings take precedence over the characters below
syn match quintOper "==\|!=\|=>\|->\|<-\|<=\|>=\|[+\-*/%^<>=!.]"
syn match quintDelim "[,:;{}()\[\]]"

" identifiers
syn match quintIdent "[a-zA-Z_][a-zA-Z0-9_]*"

" numbers and strings
syn match  quintNumber '-\?\(0x[0-9a-fA-F]\([0-9a-fA-F]\|_[0-9a-fA-F]\)*\|0\|[1-9]\([0-9]\|_[0-9]\)*\)'
syn region quintString start='"' skip=+\\"+ end='"'

" comments
syn match  quintComment "//.*$"
syn region quintComment start="/\*" end="\*/" fold

" types
syn keyword quintType int str bool Set List Rec Tup

" typedefs
syn keyword quintTypedef type

" built-in values
syn keyword quintValue Bool Int Nat
syn keyword quintBoolValue false true

" conditionals
syn keyword quintCond if else

" declarations
syn keyword quintDecl module import from export const var val def pure nondet action temporal assume run

" standard operators
syn keyword quintStd not and or iff implies all any as leadsTo

" highlighting instructions
hi def link quintComment   Comment
hi def link quintIdent     Identifier
hi def link quintType      Type
hi def link quintTypedef   Typedef
hi def link quintString    String
hi def link quintNumber    Number
hi def link quintBoolValue Boolean
hi def link quintValue     Constant
hi def link quintDecl      StorageClass
hi def link quintStd       Statement
hi def link quintOper      Operator
hi def link quintCond      Conditional
hi def link quintDelim     Delimiter

let b:current_syntax = "quint"
