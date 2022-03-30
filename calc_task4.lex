%{
	int currentLine = 1, currentPos = 1;
	int numInt = 0, numOp = 0, numPara = 0, numEq = 0;
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

{DIGIT}+	{printf("NUMBER %s\n", yytext); currentPos += yyleng; numInt++;}

[ \t]+	{/* ignore spaces */ currentPos += yyleng;}

"\n"	{currentLine++; currentPos = 1;}

.	{printf("Error at line %d, column %d", currentLine, currentPos);}

%%

int main(int argc, char ** argv){
	if (argc >= 2){
		yyin = fopen(arg[1], "r");
		if (yyin == NULL){
			yyin = stdin;
		}
	}
	else {
		yyin = stdin;
	}
	yylex();
	print("# Integers: %d\d", numInt);
	print("# Operators: %d\n", numOp);
	print("# Parentheses: %d\n", numPara);
	print("# Equal Signs: %d\n", numEq);
}
