%{  
    #include "mini_l.tab.h"
    int num_lines = 1, num_columns = 0; 
%}

DIGIT   [0-9]
E_ID_2  [a-zA-Z][a-zA-Z0-9_]*[_]
ID      [a-zA-Z][a-zA-Z0-9_]*
CHAR    [a-zA-Z]
E_ID_1  [0-9_][a-zA-Z0-9_]*


%%
{DIGIT}+        {return NUMBER; num_columns +=yyleng;}

{E_ID_2}        {printf("Error at line %d, column %d: identifier \"%s\" cannot end with an underscore\n",
                 num_lines, num_columns, yytext); exit(-1);}

{E_ID_1}        {printf("Error at line %d, column %d: identifier \"%s\" must begin with a letter\n",
                 num_lines, num_columns, yytext); exit(-1);}

"function"      {return FUNCTION; num_columns += yyleng;}
"beginparams"   {return BEGINPARAMS; num_columns += yyleng;}
"endparams"     {return ENDPARAMS; num_columns += yyleng;}
"beginlocals"   {return BEGINLOCALS; num_columns += yyleng;}
"endlocals"     {return ENDLOCALS; num_columns += yyleng;}
"beginbody"     {return BEGINBODY; num_columns += yyleng;}
"endbody"       {return ENDBODY; num_columns += yyleng;}
"integer"       {return INTEGER; num_columns += yyleng;}
"array"         {return ARRAY; num_columns += yyleng;}
"enum"          {return ENUM; num_columns += yyleng;}
"of"            {return OF; num_columns += yyleng;}
"if"            {return IF; num_columns += yyleng;}
"then"          {return THEN; num_columns += yyleng;}
"endif"         {return ENDIF; num_columns += yyleng;}
"else"          {return ELSE; num_columns += yyleng;}
"while"         {return WHILE; num_columns += yyleng;}
"do"            {return DO; num_columns += yyleng;}
"for"           {return FOR; num_columns += yyleng;}
"beginloop"     {return BEGINLOOP; num_columns += yyleng;}
"endloop"       {return ENDLOOP; num_columns += yyleng;}
"continue"      {return CONTINUE; num_columns += yyleng;}
"read"          {return READ; num_columns += yyleng;}
"write"         {return WRITE; num_columns += yyleng;}
"and"           {return AND; num_columns += yyleng;}
"or"            {return OR; num_columns += yyleng;}
"not"           {return NOT; num_columns += yyleng;}
"true"          {return TRUE; num_columns += yyleng;}
"false"         {return FALSE; num_columns += yyleng;}
"return"        {return RETURN; num_columns += yyleng;}

"-"             {return SUB; num_columns += yyleng;} 
"+"             {return ADD; num_columns += yyleng;}
"*"             {return MULT; num_columns += yyleng;}
"/"             {return DIV; num_columns += yyleng;}
"%"             {return MOD; num_columns += yyleng;}

"=="            {return EQ; num_columns += yyleng;}
"<>"            {return NEQ; num_columns += yyleng;}
"<"             {return LT; num_columns += yyleng;}
">"             {return GT; num_columns += yyleng;}
"<="            {return LTE; num_columns += yyleng;}
">="            {return GTE; num_columns += yyleng;}

{ID}            {return IDENT; num_columns+=yyleng;} 

";"             {return SEMICOLON; num_columns += yyleng;}
":"             {return COLON; num_columns += yyleng;}
","             {return COMMA; num_columns += yyleng;}
"("             {return L_PAREN; num_columns += yyleng;}
")"             {return R_PAREN; num_columns += yyleng;}
"["             {return L_SQUARE_BRACKET;num_columns+=yyleng;}
"]"             {return R_SQUARE_BRACKET;num_columns+=yyleng;}
":="            {return ASSIGN;num_columns+=yyleng;}
[ ]             num_columns++;
\t              num_columns+=4;
"\n"           {num_lines++; num_columns = 0;}
"##"[^\n]*"\n"  num_lines++; num_columns = 1;


.               {printf("Error at line $d, column %d: unrecognized symbol \"%s\"\n", num_lines, num_columns, yytext); exit(-1);}

int main(int argc, char ** argv)
{
  //yylex();
  yyparse();
  
  return 0;
}
