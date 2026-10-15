; Cypher highlights — minimal, node names from simplificare-org/tree-sitter-cypher.

(reserved_word) @keyword
(comment) @comment @spell
(string_literal) @string
(escaped_char) @string.escape

(integer_literal) @number
(decimal_integer) @number
(hex_integer) @number
(octal_integer) @number
(regular_decimal_real) @number.float
(exponent_decimal_real) @number.float
(double_literal) @number.float

(boolean_literal) @boolean
(null_literal) @constant.builtin

(parameter) @attribute
(label_name) @type
(rel_type_name) @type
(property_key_name) @property
(function_name) @function.call
(variable) @variable
(schema_name) @module
