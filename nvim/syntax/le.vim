" Logical English 2 (.le) syntax highlighting.
"
" Keyword tables and rule order mirror the LE editor's Monaco tokenizer
" (editor/src/le-language.ts of LogicalEnglish2), whose lexicon is
" i18n/keywords.csv. Generated from that CSV; regenerate when upstream
" changes it. Colours come from the colourscheme via standard groups.

if exists('b:current_syntax')
  finish
endif

" --- punctuation ------------------------------------------------------
syn match leBracket   "[{}()\[\]]"
syn match leOperator  "[<>!]=\?"
syn match leDelimiter "[.,:]"

" --- comments: % to end of line, /* */ with nesting, % TODO -----------
syn region leComment start="/\*" end="\*/" contains=leComment
syn match  leComment "%[^\n]*"
syn match  leTodo    "%\s*TODO\>.*"

" --- strings: double and single quoted ---------------------------------
syn region leString start=+"+ skip=+\\\|\\"+ end=+"+
syn match  leString "'[^'\n]*'"

" --- numbers (a date reads as a number, tried first) --------------------
syn match leNumber "\d\{4}-\d\{2}-\d\{2\}"
syn match leNumber "\d\+\([.,]\d\+\)\?"

" --- variables: *placeholders*, Capitalized IDs ------------------------
syn match leVariable "\*[^*\n]\+\*"
syn match leVariable "\<[A-Z][A-Z0-9_]*\>"

" --- prepositions and copulas standing alone ---------------------------
syn match leTemplateWord "\<\%(between\|within\|under\|from\|that\|over\|than\|with\|into\|were\|and\|are\|the\|was\|for\|an\|is\|in\|by\|to\|at\|on\|or\|of\|as\|a\)\>"
syn match leTemplateWord "\<\%(have\|that\|were\|been\|says\|does\|did\|was\|has\|had\|are\|the\|an\|is\|do\|a\)\>"

" --- variable phrases: article/each/which [qualifier] word -------------
syn match leVariable "\<\%(which\|some\|what\|each\|the\|an\|a\)\>[ \t]\+\%(\<\%(previous\|original\|current\|seventh\|another\|second\|fourth\|eighth\|single\|given\|other\|third\|ninth\|sixth\|fifth\|tenth\|first\|next\|same\|last\|new\)\>[ \t]\+\)\?[0-9A-Za-z_]\+"

" --- copula followed by a preposition: "is a", "was of", ... -----------
syn match leTemplateWord "\<\%(have\|that\|were\|been\|says\|does\|did\|was\|has\|had\|are\|the\|an\|is\|do\|a\)\>[ \t]\+\<\%(between\|within\|under\|from\|that\|over\|than\|with\|into\|were\|and\|are\|the\|was\|for\|an\|is\|in\|by\|to\|at\|on\|or\|of\|as\|a\)\>"

" --- expects answers / expects changes ---------------------------------
syn match leExpects "\<\%(expects\)[ \t]\+\%(answers\|changes)\)\>"

" --- and / or opening a line -------------------------------------------
syn match leKeyword "^\s*\%(and\|or\)\>"

" --- structural: if, if and only if, for all cases in which, ... -------
syn match leKeyword "\<\%(which[ \t]\+minimal[ \t]\+change[ \t]\+to[ \t]\+the[ \t]\+scenario[ \t]\+makes[ \t]\+it[ \t]\+the[ \t]\+case[ \t]\+that\|which[ \t]\+minimal[ \t]\+changes[ \t]\+to[ \t]\+the[ \t]\+scenario[ \t]\+make[ \t]\+it[ \t]\+the[ \t]\+case[ \t]\+that\|this[ \t]\+constraint[ \t]\+replaces[ \t]\+constraint\|scenario[ \t]\+facts[ \t]\+require[ \t]\+provenance\|the[ \t]\+minimum[ \t]\+cycle[ \t]\+time[ \t]\+is\|includes[ \t]\+these[ \t]\+resources\|it[ \t]\+must[ \t]\+not[ \t]\+be[ \t]\+true[ \t]\+that\|the[ \t]\+maximum[ \t]\+real[ \t]\+time[ \t]\+is\|it[ \t]\+is[ \t]\+not[ \t]\+the[ \t]\+case[ \t]\+that\|includes[ \t]\+these[ \t]\+services\|for[ \t]\+all[ \t]\+cases[ \t]\+in[ \t]\+which\|this[ \t]\+law[ \t]\+replaces[ \t]\+law\|it[ \t]\+is[ \t]\+the[ \t]\+case[ \t]\+that\|the[ \t]\+maximum[ \t]\+time[ \t]\+is\|not[ \t]\+the[ \t]\+case[ \t]\+that\|the[ \t]\+goal[ \t]\+is[ \t]\+that\|at[ \t]\+least[ \t]\+one[ \t]\+of\|according[ \t]\+to\|as[ \t]\+stated[ \t]\+in\|unique[ \t]\+match\|loaded[ \t]\+from\|first[ \t]\+match\|all[ \t]\+matches\|and[ \t]\+unless\|such[ \t]\+that\|initially\|terminate\|otherwise\|the[ \t]\+table\|includes\|initiate\|only[ \t]\+if\|average\|minimum\|maximum\|section\|becomes\|extends\|because\|either\|any[ \t]\+of\|all[ \t]\+of\|unless\|count\|when\|then\|sum\|min\|max\|if\|if\)\>"

" --- section headers (the templates/... headers need their colon) ------
syn match leHeader "\<\%(the[ \t]\+target[ \t]\+language[ \t]\+is\|the[ \t]\+knowledge[ \t]\+base\|the[ \t]\+constants[ \t]\+are\|the[ \t]\+ontology[ \t]\+is\|the[ \t]\+contract\|scenario\|query\)\>"
syn match leHeader "\%(the[ \t]\+prolog[ \t]\+events[ \t]\+are\|the[ \t]\+predicates[ \t]\+are\|the[ \t]\+templates[ \t]\+are\|the[ \t]\+functions[ \t]\+are\|the[ \t]\+fluents[ \t]\+are\|the[ \t]\+actions[ \t]\+are\|the[ \t]\+events[ \t]\+are\):"

" --- template trailers: ; unknown, ; opposite, ; judged, ... -----------
syn match leAddition "\<\%(scenario[ \t]\+element\|prepositional\|open[ \t]\+textured\|via[ \t]\+service\|evaluative\|by[ \t]\+default\|composite\|assumable\|undefined\|memorable\|opposite\|known[ \t]\+as\|memoised\|memoized\|synonym\|unknown\|assumed\|judged\|cached\)\>"

highlight default link leHeader       PreProc
highlight default link leKeyword      Keyword
highlight default link leExpects      Keyword
highlight default link leAddition     Keyword
highlight default link leVariable     Identifier
highlight default link leTemplateWord Constant
highlight default link leString       String
highlight default link leNumber       Number
highlight default link leComment      Comment
highlight default link leTodo         Todo
highlight default link leBracket      Delimiter
highlight default link leDelimiter    Delimiter
highlight default link leOperator     Operator

let b:current_syntax = 'le'
