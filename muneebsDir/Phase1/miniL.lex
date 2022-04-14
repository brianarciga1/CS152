   /* cs152-miniL phase1 */
  
%{   
   /* write your C code here for definitions of variables and including headers */
   int currLine = 1;
   int currPos = 1;
%}

   /* some common rules */
   DIGIT [0-9]

%%
   /* specific lexer rules in regex */
   /*reserved words */
   "function"	{printf("FUNCTION"); currPos += yyleng;}
   "beginparams"   {printf("BEGIN_PARAMS"); currPos += yyleng;}
   "integer"   {printf("INTEGER"); currPos += yyleng;}
   "endparams"   {printf("END_PARAMS"); currPos += yyleng;}
   "beginlocals"   {printf("BEGIN_LOCALS"); currPos += yyleng;}
   "endlocals"   {printf("END_LOCALS"); currPos += yyleng;}
   "beginbody"   {prinf("BEGIN_BODY"); currPos += yyleng;}
   "then"   {printf("THEN"); currPos += yyleng;}
   "return"   {printf("RETURN"); currPos += yyleng;}
   "endif"   {printf("ENDIF"); currPos += yyleng;}
   "endbody"   {printf("END_BODY"); currPos += yyleng;}
   
   /*operators */
   "-"   {printf("SUB\n"); currPos += yyleng;}
   "+"   {printf("ADD\n"); currPos += yyleng;}
   "*"   {printf("MULT\n"); currPos += yyleng;}
   "/"   {printf("DIV\n"); currPos += yyleng;}
   "%"   {printf("MOD\n"); currPos += yyleng;}

   /*symbosl*/
   "<"   {printf("LT\n"); currPos += yyleng;} 
   ">"   {printf("GT\n"); currPos += yyleng;}
   "=="   {printf("EQUAL\n"); currPos += yyleng;}
   "<="   {printf("LEQ\n"); currPos += yyleng;}
   ">="   {printf("GEQ\n"); currPos += yyleng;}
   ":"   {printf("COLON\n"); currPos += yyleng;}
   ";"   {printf("SEMICOLN\n"); currPos += yyleng;}
   ":="  {printf("ASSIGN\n"); currPos += yyleng;}

   /*identifiers*/
   {DIGIT}+   {printf("NUMBER %s\n", yytext); currPos += yyleng;}
   [a-zA-Z]   {printf("IDENT %S\n", yytext); currPos += yyleng;}

   /*new line stuff*/
   [ \t]+    {currPos += yyleng;}
   "\n"   {currLine++; currPos = 1;};
   
   /*errors*/
   . {printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n"; currPos += yyleng;)}
   
%%
	/* C functions used in lexer */

int main(int argc, char ** argv)
{
   if(argc >= 2){
      yyin = fopen(argv[1], "r");
      if (yyin == NULL){
         yyin = stdin;
      }
   }
   else {
      yyin = stdin;
   }
   yylex();
}
