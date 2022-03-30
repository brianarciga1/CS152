%{
	int currentLine = 1, currentPos = 1;
%}

DIGIT [0-9]

%%

"+" {printf("PLUS\n"); currentPos += yyleng;}
"-" {printf("MINUS\n"); currentPos += yyleng;}
"*" {printf("MULT\n"); currentPos += yyleng;}
"/" {printf("DIV\n"); currentPos += yyleng;}
"(" {printf("L_PAREN\n"); currentPos += yyleng;}
")" {printf("R_PAREN\n"); currentPos += yyleng;}
"=" {printf("EQUAL\n"); currentPos += yyleng;}

{DIGIT}+	{printf("NUMBER %s\n", yytext); currentPos += yyleng;}

[ \t]+	{/* ignore spaces */ currentPos += yyleng;}

"\n"	{currentLine++; currentPos = 1;}

.	{printf("Error at line %d, column %d", currentLine, currentPos);}

%%

int main(int argc, char ** argv){
	yylex();
}
