; Embedded Cypher in Python: a `# cypher` comment tags what follows.
;
; - inside a list, above the first string: every string in the list is Cypher
;   (one statement each; adjacent-string concatenations are combined);
; - directly inside a call's arguments, above a string: that string is.

((list
   (comment) @comment
   (string
     (string_content) @injection.content))
  (#match? @comment "^#\\s*cypher")
  (#set! injection.language "cypher"))

((list
   (comment) @comment
   (concatenated_string
     (string
       (string_content) @injection.content)))
  (#match? @comment "^#\\s*cypher")
  (#set! injection.language "cypher")
  (#set! injection.combined true))

((argument_list
   (comment) @comment
   (string
     (string_content) @injection.content))
  (#match? @comment "^#\\s*cypher")
  (#set! injection.language "cypher"))
