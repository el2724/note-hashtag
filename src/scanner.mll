{ open Parser }

let lowercase = ['a'-'z']
let uppercase = ['A'-'Z']
let letter = lowercase | uppercase
let digit = ['0'-'9']

rule token = parse
| ['\n' '\r' ';'] { SEP }
| [' ' '\t'] { token lexbuf }
| '+' { PLUS }
| '-' { MINUS }
| '*' { TIMES }
| '/' { DIVIDE }
| '%' { MOD }
| '=' { ASSIGN }
| ".(" { DOT_LPAREN }
| '.' { CONCAT }
| "true" { LIT_BOOL(true) }
| "false" { LIT_BOOL(false) }
| digit+ as lit { LIT_INT(int_of_string lit) }
| '\"' ([^ '\"']* as str) '\"' { LIT_STR(str) }
| (lowercase | '_') (letter | digit | '_')* as lit { ID_VAR(lit) }
| uppercase (letter | digit | '_')* as lit { ID_FUN(lit) }
| '(' { LPAREN }
| ')' { RPAREN }
| '[' { LBRACK }
| ']' { RBRACK }
| '{' { LBRACE }
| '}' { RBRACE }
| eof { EOF }