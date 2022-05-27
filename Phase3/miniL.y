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
  struct S {
  	char* code;
  } statement;
  struct E {
  	char* place;
	char *code;
	bool arr;
  } expression;
} // union of all the data type used by vvlval

%error-verbose
%start prog_start
%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY ENUM OF IF THEN END_IF ELSE FOR WHILE DO BEGIN_LOOP END_LOOP CONTINUE READ WRITE AND OR NOT TRUE FALSE RETURN MINUS ADD MULT DIV MOD EQ NEQ LT GT LTE GTE SEMICOLON COLON COMMA L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET ASSIGN 
%token <num_val> NUMBER
%token <id_val> IDENT
%type <expression> function FuncIdent declarations declaration vars var expressions expression Ident /*identifiers*/
%type <expression> bool_expr relation_and_expr relation_expr_inv relation_expr comp multiplicative-expr term
%type <statement> statements statement

%left ASSIGN EQ NEQ LT LTE GT GTE ADD MINUS MULT DIV MOD AND OR
%right NOT

%%
/*PROGRAM*/
prog_start:    %empty
    {
    	if (!mainFunc){
		printf("No main function was declared!\n");
	}
    }
    | function prog_start
    {
    }
    ;

/*FUNCTION* DONE/
function: FUNCTION FuncIdent SEMICOLON BEGINPARAMS declarations ENDPARAMS BEGINLOCALS declarations ENDLOCALS BEGINBODY statements ENDBODY
    {
	std::string temp = "func ";
	temp.append($2.place);
	temp.append("\n");
	std::string s = $2.place;
	if( s == "main"){
		mainFunc = true;
	}
	temp.append($5.code);
	std::string decs = $5.code;
	int decNum = 0;
	while(decs.find(".") != std::string::npos){
		int pos = decs.find(".");
		decs.replace(pos, 1, "=");
		std::string part = ", $" + std::to_string(decNum) + "\n";
		decNum++;
		decs.replace(decs.find("\n", pos), 1, part);
	}
	temp.append(decs);
	
	temp.append($8.code);
	std::string statements = $11.code;
	if (statements.find("continue") != std::string::npos){
		printf("ERROR: Continue outside loop in function %s\n", $2.place);
	}
	temp.append(statements);
	temp.append("endfunc\n\n");
	printf(temp.c_str());
    }
    ;

/*DECLARATION* DONE/
declarations: declaration SEMICOLON declarations
    {
    	std::string temp;
	temp.append($1.code);
	temp.append($3.code);
	$$.code = strdup(temp.c_str());
	$$.place=strdup("");
    }
    | %empty
    {
    	$$.place = strdup("");
	$$.code = strdup("");
    }
    ;
    
declaration: Idents COLON INTEGER
    {
    	int left = 0;
	int right = 0;
	std::string parse($1.place);
	std::string temp;
	bool ex = false;
	while(!ex) {
		right = parse.find("|", left);
		temp.append(".");
		if (right == std::string::npos) {
			std::string ident = parse.substr(left, right);
			if (reserved.find(ident) != reserved.end()) {
				printf("Identifier %s's name is a reserved word.\n", ident.c_str());
			}
			if (funcs.find(ident) != funcs.end() || varTemp.find(ident) != varTemp.end()) {
			printf("Identifier %s is previously declared.\n", ident.c_str());
			}
			else {
				varTemp[ident] = ident;
				arrSize[ident] = 1;
			}
			temp.append(ident);
			ex = true;
		}
		else {
			std::string ident = parse.substr(left, right - left);
			if(reserved.find(ident) != reserved.end()) {
				printf("Identifier %s's name is a reserved word.\n", ident.c_str());
			}
			if (funcs.find(ident) != funcs.end() || varTemp.find(ident) != varTemp.end()){
				printf("Identifier %s is previously declared.\n", ident.c_str());
			}
			else {
				varTemp[ident] = ident;
				arrSize[ident] = 1;
			}
			temp.append(ident);
			left = right + 1;
		}
		temp.append("\n");
	}
	$$.code = strdup(temp.c_str());
	$$.place = strdup("");
    }
    | Ident COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER
    {
    	size_t left = 0;
	size_t right = 0;
	std::string parse($1.place);
	std::string temp;
	bool ex = false;
	while(!ex) {
		right = parse.find("|", left);
		temp.append(".[]");
		if (right == std::string::npos) {
			std::string ident = parse.substr(left, right);
			if(reserved.find(ident) != reserved.end()){
			printf("Identifier %s's name is a reserved word.\n", ident.c_str());
		}
		if (funcs.find(ident) != funcs.end() || varTemp.find(ident) != varTemp.end()) {
			printf("Identifier %s is previously declared.\n", ident.c_str());
		}
		else {
			if ($5 <= 0) {
				printf("Declaring array ident %s of size <= 0.\n", ident.c_str());
			}
			varTemp[ident] = ident;
			arrSize[ident] = $5;
		}
		temp.append(ident);
		ex = true;
	}
	else {
		std::string ident = parse.substr(left, right - left);
		if(reserved.find(ident) != reserved.end()) {
			printf("Identifier %s's name is a reserved word.\n", ident.c_str());
		}
		if(funcs.find(ident) != funcs.end() || varTemp.find(ident) != varTemp.end()) {
			printf("Identifier %s is previously declared.\n", ident.c_str());
		}
		else {
			if($5 <= 0) {
				printf("Declaring array ident %s of size <= 0.\n", ident.c_str());
			}
			varTemp[ident] = ident;
			arrSize[ident] = $5;
		}
		temp.append(ident);
		left = right + 1;
	}
	temp.append(", ");
	temp.append(std::to_string($5));
	temp.append("\n");
    }
$$.code = strdup(temp.c_str());
$$.place = strdup("");
}
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

void yyerror(const char* msg)
{
	extern int yylineno; // defined and maintained in lex file
	extern char *yytext; // defined and maintained in lex file
	printf("%s on line %d at char %d at symbol \"%s\"\n", msg, yylineno, currPos, yytext);
	exit(1);
}

std::string new_temp(){
	std::string t = "t" + std::to_string(tempCount);
	tempCount++;
	return t;
}

std::string new_label(){
	std::string l = "L" + std::to_string(labelCount);
	labelCount++;
	return l;
}
