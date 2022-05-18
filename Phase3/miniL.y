/* cs152-miniL phase3 */
%{
 #define YY_NO_INPUT
 #include <stdio.h>
 #include <stdlib.h>
 #include <map>
 #include <string.h>
 #include <set>
 
 int tempCount = 0;
 int labelCount = 0;
 extern int currLine;
 extern int currPos;
 std::map<std::string, std::string> varTemp;
 std::map<std::string, int> arrSize;
 FILE * yyin;
 
 bool mainFunc = false;
 std::set<std::string> funcs;
 std::set<std::string> reserved {"NUMBER", "IDENT", "FUNCTION", "BEGIN_PARAMS", "END_PARAMS", "BEGIN_LOCALS", "END_LOCALS", 
 "BEGIN_BODY", "END_BODY", "INTEGER", "ARRAY", "ENUM", "OF", "IF", "THEN", "END_IF", "ELSE", "FOR", "WHILE", "DO", "BEGIN_LOOP", 
 "END_LOOP", "CONTINUE", "READ", "WRITE", "AND", "OR", "NOT", "TRUE", "FALSE", "RETURN", "MINUS", "ADD", "MULT", "DIV", "MOD", 
 "EQ", "NEQ", "LT", "GT", "LTE", "GTE", "SEMICOLON", "COLON", "COMMA", "L_PAREN", "R_PAREN", "L_SQUARE_BRACKET", "R_SQUARE_BRACKET", "ASSIGN", 
 "functions", "function", "declarations", "declaration", "identifiers", "statements", "statement", "bool_expr", 
 "relation_and_expr", "relation_expr", "relation_expr_inv", "comp", "expressions", "expression", "multiplicative-expr", "term", "vars", "var"};
 
 void yyerror(const char *msg);
 int yylex();
 std::string new_temp();
 std::string new_label();
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
/*PROGRAM*/
prog_start: functions { printf("prog_start -> functions\n");}
	| error {yyerrok; yyclearin;}
	;
	
/*FUNCTION*/	
functions: /*empty*/ {printf("functions -> epsilon\n");}
	| function functions	{printf("functions -> function functions\n");}
        ;
function: FUNCTION IDENT SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY
	{printf("function -> FUNCTION IDENT SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY\n");}
        ;

/*DECLARATION*/
declarations: /*empty*/ {printf("declarations -> epsilon\n");}
	| declaration SEMICOLON declarations {printf("declarations -> declaration SEMICOLON declarations\n");}
	;
declaration: identifiers COLON INTEGER {printf("declaration -> identifiers COLON INTEGER\n");}
	| identifiers COLON ENUM L_PAREN identifiers R_PAREN {printf("declaration -> identifiers COLON ENUM L_PAREN identifiers R_PAREN\n");}
	| identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER {printf("declaration -> identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER\n");}
	;

/*IDENTIFIER*/
identifiers: IDENT {printf("identifiers -> IDENT\n");}
	| IDENT COMMA identifiers {printf("identifiers -> IDENT COMMA identifiers");}
	;

/*STATEMENT*/
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
	
/*BOOL-EXPR*/
bool_expr: relation_and_expr {printf("bool_expr -> relation_and_expr\n");}
	| relation_and_expr OR bool_expr {printf("bool_expr -> relation_and_expr OR bool_expr\n");}
        ;
	
/*RELATION-AND-EXPR*/
relation_and_expr: relation_expr {printf("relation_and_expr -> relation_expr");}
	| relation_and_expr AND relation_expr {printf("relation_and_expr -> relation_and_expr AND relation_expr\n");}
	;
	
/*RELATION_EXPR*/
relation_expr: expression comp expression {printf("relation_expr -> expression comp expression\n");}
	| NOT TRUE {printf("relation_expr -> NOT TRUE\n");}
	| NOT FALSE {printf("relation_expr -> NOT FALSE\n");}
	| NOT expression comp expression {printf("relation_expr -> NOT expression comp expression\n");}
	| NOT L_PAREN bool_expr R_PAREN {printf("relation_expr -> NOT L_PAREN bool_expr R_PAREN\n");}
        | TRUE {printf("relation_expr -> TRUE\n");}
        | FALSE {printf("relation_expr -> FALSE\n");}
        | L_PAREN bool_expr R_PAREN {printf("relation_expr -> L_PAREN bool_expr R_PAREN\n");}
        ;

/*COMP*/
comp: EQ {printf("comp -> EQ\n");}
	| NEQ {printf("comp -> NEQ\n");}
	| LT {printf("comp -> LT\n");}
	| GT {printf("comp -> GT\n");}
	| LTE {printf("comp -> LTE\n");}
	| GTE {printf("comp -> GTE\n");}
	;
	
/*EXPRESSION*/
expressions: /*empty*/ {printf("expressions -> epsilon\n");}
	| expression {printf("expressions -> expression\n");}
	| expression COMMA expressions {printf("expressions -> expression COMMA expressions\n");};
expression: multiplicative_expr {printf("expression -> multiplicative_expr\n");}
	| multiplicative_expr ADD expression {printf("expression -> multiplicative_expr ADD expression\n");}
	| multiplicative_expr MINUS expression {printf("expression -> multiplicative_expr MINUS expression\n");}      
	; 
	
/*MULTIPLICATIVE-EXPR*/	
multiplicative_expr: term {printf("multiplicative_expr -> term\n");}
	| term MULT term {printf("multiplicative_expr -> term MULT term\n");}
	| term DIV term {printf("multiplicative_expr -> term DIV term\n");}
	| term MOD term {printf("multiplicative_expr -> term MOD term\n");}   
	;
	
/*TERM*/	
term: var {printf("term -> var\n");}
	| NUMBER {printf("term -> NUMBER\n");}
	| L_PAREN expression R_PAREN {printf("term -> L_PAREN expression R_PAREN\n");}
	| IDENT L_PAREN expressions R_PAREN {printf("term -> IDENT L_PAREN expressions R_PAREN\n");}
	| MINUS var {printf("term -> MINUS var\n");}
	| MINUS NUMBER {printf("term -> MINUS NUMBER\n");}
	| MINUS L_PAREN expression R_PAREN {printf("term -> MINUS L_PAREN expression R_PAREN\n");}
	;

/*VAR*/
vars: var {printf("vars -> var\n");}
	| var COMMA vars {printf("vars -> var COMMA vars\n");}
	;
var: IDENT {printf("var -> IDENT\n");}
	| IDENT L_SQUARE_BRACKET expression R_SQUARE_BRACKET {printf("var -> IDENT L_SQUARE_BRACKET expression R_SQUARE_BRACKET\n");}
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
