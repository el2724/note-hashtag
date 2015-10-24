%{ open Ast %}

%token SEP
%token LPAREN RPAREN LBRACK RBRACK LBRACE RBRACE DOT_LPAREN CONCAT
%token PLUS MINUS TIMES DIVIDE MOD
%token EQ NEQ LT LTE GT GTE
%token NOT AND OR
%token ASSIGN
%token EOF

%token <bytes> ID_VAR
%token <bytes> ID_FUN

%token <bool> LIT_BOOL
%token <int> LIT_INT
%token <float> LIT_FLOAT
%token <bytes> LIT_STR

%left SEP
%right ASSIGN
%left CONCAT
%left OR
%left AND
/* Note: "1 == 1 == 1" is valid grammar, though it's a type error. */
%left EQ NEQ LT LTE GT GTE
%left PLUS MINUS
%left TIMES DIVIDE MOD

/* Unary Operators */
%nonassoc NOT

%start prog
%type < Ast.expr> expr

%%

expr:
| apply     { $1 }
| non_apply { $1 }
| arith     { $1 }
| bool      { $1 }
| expr CONCAT expr { Binop($1, Concat, $3) }
| ID_VAR DOT_LPAREN expr RPAREN { ArrIdx($1, $3) }
| LBRACK stmt_list RBRACK { Arr(List.rev $2) }
| LBRACE stmt_list RBRACE { ArrMusic(List.rev $2) }

stmt_list:
| /* nothing */ { [] }
| stmt_list non_apply { $2 :: $1 }

apply:
| ID_FUN          { FunApply($1, []) }
| apply non_apply { match $1 with
                    | FunApply(x, y) -> FunApply(x, $2 :: y)
                    | _ -> raise (Failure("apply must be FunApply")) }

non_apply:
| LPAREN expr RPAREN { $2 }
| lit                { $1 }
| ID_VAR             { IdVar($1) }

lit:
| LIT_BOOL         { LitBool($1) }
| LIT_INT          { LitInt($1) }
| LIT_FLOAT        { LitFloat($1) }
| LIT_STR          { LitStr($1) }

arith:
|      MINUS  expr { Binop(LitInt(-1), Mul, $2) }
| expr PLUS   expr { Binop($1, Add, $3) }
| expr MINUS  expr { Binop($1, Sub, $3) }
| expr TIMES  expr { Binop($1, Mul, $3) }
| expr DIVIDE expr { Binop($1, Div, $3) }
| expr MOD    expr { Binop($1, Mod, $3) }

bool:
| cmp { $1 }
| logic { $1 }

cmp:
| expr EQ  expr { Binop($1, Eq,  $3) }
| expr NEQ expr { Binop($1, Neq, $3) }
| expr LT  expr { Binop($1, Lt,  $3) }
| expr LTE expr { Binop($1, Lte, $3) }
| expr GT  expr { Binop($3, Lt,  $1) }
| expr GTE expr { Binop($3, Lte, $1) }

logic:
|      NOT expr { Uniop(Not, $2) }
| expr AND expr { Binop($1, And, $3) }
| expr OR  expr { Binop($1, Or,  $3) }
