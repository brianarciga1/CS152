%{
    #include <stdio.h>
    #include <stdlib.h>
    void yyerror(const char* msg);
    extern int currLine;
    extern int currPos;
    FILE* yyin;
%}

%union{
    int num_val;
    char* id_val;
}

%error-verbose
%start program
%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY ENUM OF IF THEN ENDIF ELSE WHILE DO BEGINLOOP ENDLOOP CONTINUE READ WRITE TRUE FALSE RETURN SEMICOLON COLON COMMA L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET ASSIGN
%token <id_val> IDENT
%token <num_val> NUMBER
%left ADD MINUS
%left EQ NEQ GT GTE LT LTE
%right NOT
%left AND OR
%right ASSIGN
%left MULT DIV MOD

%%
program: functions                                              {printf("program -> functions\n");}
        ;
functions:                                                      {printf("functions -> epsilon\n");}
        | function functions                                    {printf("functions -> function functions\n");}
        ;
function: FUNCTION IDENT SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY repeatedstmts END_BODY  {printf("function -> FUNCTION IDENT SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY repeatedstmts END_BODY\n");}
        ;
declarations:                                                   {printf("declarations -> epsilon\n");}
        | declaration SEMICOLON declarations                    {printf("declarations -> declaration SEMICOLON declarations\n");}
        ;
repeatedstmts: statement SEMICOLON chainedstmts                 {printf("repeatedstmts -> statement SEMICOLON chainedstmts\n");}
        ;
chainedstmts:                                                   {printf("chainedstmts -> epsilon\n");}
        | statement SEMICOLON chainedstmts                      {printf("chainedstmts -> statement SEMICOLON chainedstmts\n");}
        ;
declaration: IDENT identifiers COLON decdef                     {printf("declaration -> IDENT identifiers COLON decdef\n");}
        ;
identifiers:                                                    {printf("identifiers -> epsilon\n");}
        | COMMA IDENT identifiers                               {printf("identifiers -> COMMA IDENT identifiers\n");}
        ;
decdef: arraydec INTEGER                                        {printf("decdef -> arraydec INTEGER\n");}
        | ENUM L_PAREN identifiers R_PAREN                      {printf("decdef -> ENUM L_PAREN identifiers R_PAREN\n");}
        ;
arraydec:                                                       {printf("arraydec -> epsilon\n");}
        | ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF     {printf("arraydec -> ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF\n");}
        ;
statement: var ASSIGN expression                                {printf("statement -> var ASSIGN expression\n");}
        | IF boolexpr THEN repeatedstmts elsestmt ENDIF         {printf("statement -> IF boolexpr THEN repeatedstmts elsestmt ENDIF\n");}
        | WHILE boolexpr BEGINLOOP repeatedstmts ENDLOOP        {printf("statement -> WHILE boolexpr BEGINLOOP repeatedstmts ENDLOOP\n");}
        | DO BEGINLOOP repeatedstmts ENDLOOP WHILE boolexpr     {printf("statement -> DO BEGINLOOP repeatedstmts ENDLOOP WHILE boolexpr\n");}
        | READ vars                                             {printf("statement -> READ vars\n");}
        | WRITE vars                                            {printf("statement -> WRITE vars\n");}
        | CONTINUE                                              {printf("statement -> CONTINUE\n");}
        | RETURN expression                                     {printf("statement -> RETURN expression\n");}
        ;
elsestmt:                                                       {printf("elsestmt -> epsilon\n");}  
        | ELSE repeatedstmts                                    {printf("elsestmt -> repeatedstmts \n");}
        ;
vars: var morevars                                              {printf("vars -> var morevars\n");}
        ;
morevars:                                                       {printf("morevars -> epsilon\n");}
        | COMMA var morevars                                    {printf("morevars -> COMMA var morevars\n");} 
        ;
boolexpr: relation_and_expr or_rel_and_expr                     {printf("boolexpr -> relation_and_expr or_rel_and_expr\n");}
        ;
or_rel_and_expr:                                                {printf("or_rel_and_expr -> epsilon\n");}
        | OR relation_and_expr or_rel_and_expr                  {printf("or_rel_and_expr -> OR relation_and_expr or_rel_and_expr\n");}
        ;
relation_and_expr: relation_expr and_rel_expr                    {printf("relation_and_expr -> relation_expr and_rel_expr\n");}
        ;
and_rel_expr:                                                   {printf("and_rel_expr -> epsilon\n");} 
        | AND relation_expr and_rel_expr                        {printf("and_rel_expr -> AND relation_expr and_rel_expr\n");}
        ;

relation_expr: NOT expression comp expression                   { printf("relation_expr -> NOT expression comp expression\n"); }
               | NOT TRUE                                       { printf("relation_expr -> NOT TRUE\n"); }
               | NOT FALSE                                      { printf("relation_expr -> NOT FALSE\n"); }
               | NOT L_PAREN boolexpr R_PAREN                   { printf("relation_expr -> NOT L_PAREN boolexpr R_PAREN\n"); }
               | expression comp expression                     { printf("relation_expr -> expression comp expression\n"); }
               | TRUE                                           { printf("relation_expr -> TRUE\n"); }
               | FALSE                                          { printf("relation_expr -> FALSE\n"); }
               | L_PAREN boolexpr R_PAREN                       { printf("relation_expr -> L_PAREN boolexpr R_PAREN\n"); }        
               ;

comp: EQ                                                        { printf("comp -> EQ\n"); }
      | NEQ                                                     { printf("comp -> NEQ\n"); }
      | LT                                                      { printf("comp -> LT\n"); }
      | GT                                                      { printf("comp -> GT\n"); }
      | LTE                                                     { printf("comp -> LTE\n"); }
      | GTE                                                     { printf("comp -> GTE\n"); }
      ;  

expression: multiplicative_expr                                 { printf("expression -> multiplicative_expr\n"); }
            | multiplicative_expr ADD multiplicative_expr       { printf("expression -> multiplicative_expr ADD multiplicative_expr\n"); }
            | multiplicative_expr MINUS multiplicative_expr     { printf("expression -> multiplicative_expr MINUS multiplicative_expr\n"); }      
            ;    

multiplicative_expr: term                                       { printf("multiplicative_expr -> term\n"); }
                     | term MULT term                           { printf("multiplicative_expr -> term MULT term\n"); }
                     | term DIV term                            { printf("multiplicative_expr -> term DIV term\n"); }
                     | term MOD term                            { printf("multiplicative_expr -> term MOD term\n"); }   
                     ;

term: MINUS var                                                 { printf("term -> MINUS var\n"); } 
      | MINUS NUMBER                                            { printf("term -> MINUS NUMBER\n"); }
      | MINUS L_PAREN expression R_PAREN                        { printf("term -> MINUS L_PAREN expression R_PAREN\n"); }
      | var                                                     { printf("term -> var\n"); }
      | NUMBER                                                  { printf("term -> NUMBER\n"); }
      | L_PAREN expression R_PAREN                              { printf("term -> L_PAREN expression R_PAREN\n"); }
      | IDENT L_PAREN optional_exprs R_PAREN                    { printf("term -> identifier L_PAREN optional_exprs R_PAREN\n"); }
      ;

optional_exprs: /* empty */                                     { printf("optional_exprs -> epsilon\n"); }
                | expression chained_exprs                      { printf("optional_exprs -> expression chained_exprs\n"); }
                ;

chained_exprs:  /* empty */                                     { printf("chained_exprs -> epsilon\n"); }
                | COMMA expression chained_exprs                { printf("chained_exprs -> COMMA expression chained_exprs\n"); }
                ;

var: IDENT                                                      { printf("var -> IDENT\n"); }
     | IDENT L_SQUARE_BRACKET expression R_SQUARE_BRACKET       { printf("var -> IDENT L_SQUARE_BRACKET expression R_SQUARE_BRACKET"); }
     ;    
%%

int main(int argc, char** argv) {
    if (argc == 2) {
        yyin = fopen(argv[1], "r");
    }
    yyparse();
    

    return 0;
}

void yyerror(const char* msg) {
    printf("** Line %d, position %d: %s\n", currLine, currPos, msg);
}
