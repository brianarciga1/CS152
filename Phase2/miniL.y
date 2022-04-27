    /* cs152-miniL phase2 */
%{
void yyerror(const char *msg);
%}

%union{
  /* put your types here */
}

%error-verbose
%locations

/* %start program */

%% 

  /* write your rules here */

%% 

int main(int argc, char **argv) {
   yyparse();
   return 0;
}

void yyerror(const char *msg) {
    /* implement your error handling */
}
