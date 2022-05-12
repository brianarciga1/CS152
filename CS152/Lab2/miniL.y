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

identifiers: ident {printf("identifiers -> ident\n");}
	| ident COMMA identifiers {printf("identifiers -> IDENT COMMA identifiers");}
	;

ident: IDENT {printf("ident -> IDENT %s\n", $1);}
	;

statements: /*empty*/ {printf("statements -> epsilon\n");}
	| statement SEMICOLON statements {printf("statement SEMICOLON statements\n");}
        ;
statement: var ASSIGN expression {printf("statement -> var ASSIGN expression\n");}
	| IF bool_expr THEN statements END_IF {printf("statement -> IF bool_expr THEN statements END_IF\n");}
	| IF bool_expr THEN statements ELSE statements END_IF {printf("statement -> IF bool_expr THEN statements ELSE statements END_IF\n");}
	| WHILE bool_expr BEGIN_LOOP statements END_LOOP {printf("statement -> WHILE bool_expr BEGIN_LOOP statements END_LOOP\n");}
	| DO BEGIN_LOOP statements END_LOOP WHILE bool_expr {printf("statement -> DO BEGIN_LOOP statements END_LOOP WHILE bool_expr\n");}
	| READ vars {printf("statement -> READ vars\n");}
	| WRITE vars {printf("statement -> WRITE vars\n");}
	| CONTINUE {printf("statement -> CONTINUE\n");}
	| RETURN expression {printf("statement -> RETURN expression\n");}
	;
	
bool_expr: relation_and_exp {printf("bool_expr -> relation_and_exp\n");}
	| relation_and_exp OR bool_expr {printf("bool_expr -> relation_and_exp OR bool_expr\n");}
        ;
	
relation_and_exp: relation_exp {printf("relation_and_exp -> relation_exp");}
	| relation_and_exp AND relation_exp {printf("relation_and_exp -> relation_and_exp AND relation_exp\n");}
	;
	
relation_exp: expression comp expression {printf("relation_exp -> expression comp expression\n");}
	| NOT TRUE {printf("relation_exp -> NOT TRUE\n");}
	| NOT FALSE {printf("relation_exp -> NOT FALSE\n");}
	| NOT expression comp expression {printf("relation_exp -> NOT expression comp expression\n");}
	| NOT L_PAREN bool_expr R_PAREN {printf("relation_exp -> NOT L_PAREN bool_expr R_PAREN\n");}
        | TRUE {printf("relation_exp -> TRUE\n");}
        | FALSE {printf("relation_exp -> FALSE\n");}
        | L_PAREN bool_expr R_PAREN {printf("relation_exp -> L_PAREN bool_expr R_PAREN\n");}
        ;

comp: EQ {printf("comp -> EQ\n");}
	| NEQ {printf("comp -> NEQ\n");}
	| LT {printf("comp -> LT\n");}
	| GT {printf("comp -> GT\n");}
	| LTE {printf("comp -> LTE\n");}
	| GTE {printf("comp -> GTE\n");}
	;
	
expression: multiplicative_expr {printf("expression -> multiplicative_expr\n");}
	| multiplicative_expr ADD expression {printf("expression -> multiplicative_expr ADD expression\n");}
	| multiplicative_expr MINUS expression {printf("expression -> multiplicative_expr MINUS expression\n");}      
	; 
	
multiplicative_expr: term {printf("multiplicative_expr -> term\n");}
	| term MULT term {printf("multiplicative_expr -> term MULT term\n");}
	| term DIV term {printf("multiplicative_expr -> term DIV term\n");}
	| term MOD term {printf("multiplicative_expr -> term MOD term\n");}   
	;
	
term: var {printf("term -> var\n");}
	| NUMBER {printf("term -> NUMBER\n");}
	| L_PAREN expression R_PAREN {printf("term -> L_PAREN expression R_PAREN\n");}
	| ident L_PAREN expression R_PAREN {printf("term -> ident L_PAREN expression R_PAREN\n");}
	| MINUS var {printf("term -> MINUS var\n");}
	| MINUS NUMBER {printf("term -> MINUS NUMBER\n");}
	| MINUS L_PAREN expression R_PAREN {printf("term -> MINUS L_PAREN expression R_PAREN\n");}
	;

vars: {printf("vars -> epsilon\n");}
	| expression {printf("vars-> expression\n");}
	| expression COMMA vars {printf("vars -> expression COMMA vars\n");}
	;

var: ident {printf("var -> ident\n");}
	| ident L_SQUARE_BRACKET expression R_SQUARE_BRACKET {printf("var -> ident L_SQUARE_BRACKET expression R_SQUARE_BRACKET\n");}
	;

%%

int main(int argc, char **argv) {
   if (argc > 1) {
      yyin = fopen(argv[1], "r");
      if (yyin == NULL){
         printf("syntax: %s filename\n", argv[0]);
      }//end if
   }//end if
   yyparse(); // Calls yylex() for tokens.
   return 0;
}

void yyerror(const char *msg) {
   printf("** Line %d, position %d: %s\n", currLine, currPos, msg);
}
