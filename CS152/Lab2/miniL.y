    /* cs152-miniL phase2 */
%{
 #include <stdio.h>
 #include <stdlib.h>
 void yyerror(const char *msg);
 extern int currLine;
 extern int currPos;
 FILE * yyin;
%}

%union{
  int num_val;
  char* id_val;
} // union of all the data type used by vvlval

%error-verbose
%start prog_start
%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY ENUM OF IF THEN END_IF ELSE FOR WHILE DO BEGIN_LOOP END_LOOP CONTINUE READ WRITE AND OR NOT TRUE FALSE RETURN MINUS ADD MULT DIV MOD EQ NEQ LT GT LTE GTE SEMICOLON COLON COMMA L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET ASSIGN 
%token <num_val> NUMBER
%token <id_val> IDENT
%left MINUS ADD MULT DIV MOD
%left EQ NEQ LT GT LTE GTE
%left AND OR
%right NOT
%right ASSIGN


%% 
prog_start: functions	{ printf("prog_start -> functions\n");}
	;
	
functions: {printf("functions -> epsilon\n");}
	| function functions	{printf("functions -> function functions\n");}
        ;
function: FUNCTION IDENT SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY
	{printf("function -> FUNCTION IDENT SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY\n");}
        ;
	
declarations: {printf("declarations -> epsilon\n");}
        | declaration SEMICOLON declarations	{printf("declarations -> declaration SEMICOLON declarations\n");}
        ;
declaration: identifiers COLON INTEGER	{printf("declaration -> identifiers COLON INTEGER\n");}
	| identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER {printf("declaration -> identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER\n");} 
        ;

identifiers: identifier	{printf("identifiers -> identifier\n");}
        | identifier COMMA identifiers {printf("identifiers -> IDENT COMMA identifiers\n");}
        ;
identifier: IDENT {printf("identifier -> IDENT %s\n", $1);}
	;
	
statements: statement SEMICOLON statements	{printf("statements -> statement SEMICOLON statements\n");}
        ;
statement: var ASSIGN expression {printf("statement -> var ASSIGN expression\n");}
        | IF bool_expr THEN statements END_IF {printf("statement -> IF bool_expr THEN statements ENDIF\n");}
	| IF bool_expr THEN statements ELSE statements END_IF {printf("statement -> IF bool_expr THEN statements ELSE statements ENDIF\n");}
        | WHILE bool_expr BEGIN_LOOP statements END_LOOP {printf("statement -> WHILE bool_expr BEGIN_LOOP statements END_LOOP\n");}
        | DO BEGIN_LOOP statements END_LOOP WHILE bool_expr {printf("statement -> DO BEGIN_LOOP statements END_LOOP WHILE bool_expr\n");}
        | READ var {printf("statement -> READ var\n");}
        | WRITE var {printf("statement -> WRITE var\n");}
        | CONTINUE {printf("statement -> CONTINUE\n");}
        | RETURN expression {printf("statement -> RETURN expression\n");}
        ;
	
vars:           
          var {printf("vars -> var\n");}
        | var COMMA vars {printf("vars -> var COMMA vars");}
        ;

var:            
          ident {printf("var -> ident\n");}
        | ident L_SQUARE_BRACKET expression R_SQUARE_BRACKET {printf("var -> ident L_SQUARE_BRACKET expression R_SQUARE_BRACKET\n");}
        ;

bool_exp:   
          relation_and_exp {printf("bool_exp -> relation_and_exp\n");}
        | relation_and_exp OR bool_exp {printf("bool_exp -> relation_and_exp OR bool_exp\n");}
        ;

relation_and_exp:  
          relation_exp {printf("relation_and_exp -> relation_exp\n");}
        | relation_exp AND relation_and_exp {printf("relation_and_exp -> relation_exp AND relation_and_exp\n");}
        ;

relation_exp:           
          expression comp expression {printf("relation_exp -> expression comp expression\n");}
        | TRUE {printf("relation_exp -> TRUE\n");}
        | FALSE {printf("relation_exp -> FALSE\n");}
        | L_PAREN bool_exp R_PAREN {printf("relation_exp -> L_PAREN bool_exp R_PAREN\n");}
        | NOT expression comp expression {printf("relation_exp -> NOT expression comp expression\n");}
        | NOT TRUE {printf("relation_exp -> NOT TRUE\n");}
        | NOT FALSE {printf("relation_exp -> NOT FALSE\n");}
        | NOT L_PAREN bool_exp R_PAREN {printf("relation_exp -> NOT L_PAREN bool_exp R_PAREN\n");}
        ;

comp:           
          EQ {printf("comp -> EQ\n");}
        | NEQ {printf("comp -> NEQ\n");}
        | LT {printf("comp -> LT\n");}
        | GT {printf("comp -> GT\n");}
        | LTE {printf("comp -> LTE\n");}
        | GTE {printf("comp -> GTE\n");}
        ;

expressions:
          {printf("expressions -> epsilon\n");}
        | expression {printf("expressions -> expression\n");}
        | expression COMMA expressions {printf("expressions -> expression COMMA expressions\n");}

expression:   
          multiplicative_exp {printf("expression -> multiplicative_exp\n");}
        | multiplicative_exp ADD expression {printf("expression -> multiplicative_exp ADD expression\n");}
        | multiplicative_exp MINUS expression {printf("expression -> multiplicative_exp MINUS expression\n");}
        ;

multiplicative_exp:  
          term {printf("multiplicative_exp -> term\n");}
        | term MULT multiplicative_exp {printf("multiplicative_exp -> term MULT multiplicative_exp\n");}
        | term DIV multiplicative_exp {printf("multiplicative_exp -> term DIV multiplicative_exp\n");}
        | term MOD multiplicative_exp {printf("multiplicative_exp -> term MOD multiplicative_exp\n");}
        ;

term:           
          var {printf("term -> var\n");}
        | NUMBER {printf("term -> NUMBER\n");}
        | L_PAREN expression R_PAREN {printf("term -> L_PAREN expression R_PAREN\n");}
        | MINUS var {printf("term -> MINUS var\n");}
        | MINUS NUMBER {printf("term -> MINUS NUMBER\n");}
        | MINUS L_PAREN expression R_PAREN {printf("term -> MINUS L_PAREN expression R_PAREN\n");}
        | ident L_PAREN expressions R_PAREN {printf("term -> ident L_PAREN expressions R_PAREN\n");}
        ;

%%

int main(int argc, char ** argv) {
        if (argc > 1) {
                yyin = fopen(argv[1], "r");
                if (yyin == NULL) {
                        printf("syntax: %s filename", argv[0]);
                }
        }
        yyparse();
        return 0;
}

void yyerror(const char *msg) {
        printf("Error: Line %d, position %d: %s \n", currLine, currPos, msg);
}
