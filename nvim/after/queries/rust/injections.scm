; extends

; Highlight SQL in the string literal passed to sqlx's query macros.
; Unanchored on purpose: query_as! puts the row type first, and that type can
; itself be an expression (Row, Row.new(), crate::Row), so the string is not
; always the first child of the token tree.
(macro_invocation
  macro: (scoped_identifier
    path: (identifier) @_path
    name: (identifier) @_name)
  (token_tree
    [
      (string_literal ((string_content) @injection.content))
      (raw_string_literal ((string_content) @injection.content))
    ])
  (#eq? @_path "sqlx")
  (#match? @_name "query(_as|_scalar|)")
  (#set! injection.language "sql"))
