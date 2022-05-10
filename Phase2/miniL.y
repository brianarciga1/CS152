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
%start prog_start /* begin processing top-level component */
%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY ENUM OF IF THEN END_IF ELSE FOR WHILE DO BEGIN_LOOP END_LOOP CONTINUE READ WRITE TRUE FALSE RETURN SEMICOLON COLON COMMA L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET /* valid token types */
%token <num_val> NUMBER
%token <id_val> IDENT
%left MINUS ADD MULT DIV MOD
%left EQ NEQ LT GT LTE GTE
%left AND OR
%right NOT
%right ASSIGN


%% 
##program
prog_start: functions	{ printf("prog_start -> functions\n");}
	;
	
##function
functions: /*empty*/	{printf("functions -> epsilon\n");}
	| function functions	{printf("functions -> function functions\n");}
        ;
function: FUNCTION IDENT SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY
	{printf("function -> FUNCTION IDENT SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY\n");}
        ;
	
	
declarations: /*empty*/	{printf("declarations -> epsilon\n");}
        | declaration SEMICOLON declarations	{printf("declarations -> declaration SEMICOLON declarations\n");}
        ;
declaration: IDENT identifiers COLON INTEGER	{printf("declaration -> IDENT identifiers COLON INTEGER\n");}
        ;
	

identifiers: COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER	{printf("declaration -> IDENT COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER\n");}
        | COMMA IDENT identifiers                               {printf("identifiers -> COMMA IDENT identifiers\n");}
        ;
identifiers: identifier	{printf("identifiers -> identifier\n");}
identifier: IDENT {printf("ident -> IDENT %s \n", $1);}
	;
	
	
statements: statement SEMICOLON statements	{printf("statements -> statement SEMICOLON statements\n");}
        ;
statement: var ASSIGN expression {printf("statement -> var ASSIGN expression\n");}
        | IF bool_expr THEN statements ENDIF {printf("statement -> IF bool_expr THEN statements ENDIF\n");}
	| If bool_expr THEN statements ELSE statements ENDIF {printf("statement -> IF bool_expr THEN statements ELSE statements ENDIF\n");}
        | WHILE bool_expr BEGINLOOP statements ENDLOOP {printf("statement -> WHILE bool_expr BEGINLOOP statements ENDLOOP\n");}
        | DO BEGINLOOP statements ENDLOOP WHILE bool_expr {printf("statement -> DO BEGINLOOP statements ENDLOOP WHILE bool_expr\n");}
        | READ vars {printf("statement -> READ vars\n");}
        | WRITE vars {printf("statement -> WRITE vars\n");}
        | CONTINUE {printf("statement -> CONTINUE\n");}
        | RETURN expression {printf("statement -> RETURN expression\n");}
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
