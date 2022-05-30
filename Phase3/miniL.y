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
 "relation_and_expr", "relation_expr", "comp", "expressions", "expression", "multiplicative-expr", "term", "vars", "var"};
 
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
%type <expression> bool_expr relation_and_expr relation_expr comp multiplicative-expr term
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

/*FUNCTION DONE*/
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

/*DECLARATION DONE*/
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
    | identifiers COLON ENUM L_PAREN identifiers R_PAREN {printf("declaration -> identifiers COLON ENUM L_PAREN identifiers R_PAREN\n");}
    | identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER
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

/*FUNCIDENT DONE*/
FuncIdent: IDENT
    {
    	if (funcs.find($1) != funcs.end()) {
		printf("function name %s already declared.\n", $1);
	}
	else {
		funcs.insert($1);
	}
	$$.place = strdup($1);
	$$.code = strdup("");
    }
    ;
    
/*IDENT CHECK AGAIN*/
identifiers: IDENT
    {
    	$$.place = strdup($1.place);
	$$.code = strdup("");
    }
    | IDENT COMMA identifiers
    {
    	std::string temp;
	temp.append($1.place);
	temp.append("|");
	temp.append($3.place);
	$$.place = strdup(temp.c_str());
	$$.code = strdup("");
    }
    ;
    
/*    
Ident: IDENT
    {
    	$$.place = strdup($1);
	$$.code = strdup("");
    }
    ;
*/

/*STATEMENT changed to match lex*/
statements: statement SEMICOLON statements
    {
    	std::string temp;
	temp.append($1.code);
	temp.append($3.code);
	$$.code = strdup(temp.c_str());
    }
    | /* statement SEMICOLON empty*/
    {
    	$$.code = strdup($1.code);
    }
    ;

statement: var ASSIGN expression
    {
    	std::string temp;
	temp.append($1.code);
	temp.append($3.code);
	std::string middle = $3.place;
	if ($1.arr && $3.arr) {
		temp += "[]= ";
	}
	else if ($1.arr) {
		temp += "[]= ";
	}
	else if ($3.arr) {
		temp += "= ";
	}
	else {
		temp += "= ";
	}
	temp.append($1.place);
	temp.append(", ");
	temp.append(middle);
	temp += "\n";
	$$.code = strdup(temp.c_str());
    }
    | IF bool_expr THEN statements ENDIF
    {
    	std::string ifS = new_label();
	std::string after = new_label();
	std::string temp;
	temp.append($2.code);
	temp = temp + "?:= " + ifS + ", " + $2.place + "\n"; //if true, jump to :ifS and do code from $4
	temp = temp + ":= " + after + "\n"; //reached if above not true, skips $4 code by jumping to 12
	temp = temp + ": " + ifS + "\n";
	temp.append($4.code);
	temp = temp + ": " + after + "\n";
	$$.code = strdup(temp.c_str());
    }
    //////////////////////
    | IF  bool_expr THEN statements ELSE statements ENDIF
    {
    	std::string ifS = new_label();
	std::string after = new_label();
	std::string temp;
	temp.append($2.code);
	temp = temp + "?:= " + ifS + ", " + $2.place + "\n";
	temp.append($6.code);
	temp = temp + ":= " + after + "\n";
	temp = temp + ": " + ifS + "\n";
	temp.append($4.code);
	temp = temp + ": " + after + "\n";
	$$.code = strdup(temp.c_str());
    }
    |  WHILE bool_expr BEGIN_LOOP statements END_LOOP
    {
    	std::string temp;
	std::string begin = new_label();
	std::string inner = new_label();
	std::string after = new_label();
	std::string code = $4.code;
	
	size_t pos = code.find("continue");
	while (pos != std::string::npos) {
		code.replace(pos, 8, ":= " + begin);
		pos = code.find("continue");
	}
	temp.append(": ");
	temp += begin + "\n"; //defines start of while loop
	temp.append($2.code);
	temp += "?:= " + inner + ", "; //if true, jump to code
	temp.append($2.place);
	temp.append("\n");
	temp += ":= " + after + "\n";
	temp += ": " + inner + "\n";
	temp.append(code);
	temp += ":= " + begin + "\n";
	temp += ": " + after + "\n";
	$$.code = strdup(temp.c_str());
     }
     | DO BEGIN_LOOP statements END_LOOP WHILE bool_expr
     {	
     	std::string temp;
     	std::string begin = new_label();
	std::string condition = new_label();
	std::string code = $3.code;
	
	size_t pos = code.find("continue") ;
	while (pos != std::string::npos) {
		code.replace(pos, 8, ":= " + condition);
		pos = code.find("continue");
	}
	temp.append(": ");
	temp += begin + "\n";
	temp.append(code);
	temp += ": " + condition + "\n";
	temp.append($6.code);
	temp += "?:= " + begin + ", ";
	temp.append($6.place);
	temp.append("\n");
	$$.code = strdup(temp.c_str());
    }
    | READ vars
    {
    	std::string temp;
	temp.append($2.code);
	
	size_t pos = temp.find("|", 0);
	while (pos != std::string::npos) {
		temp.replace(pos, 1, "<");
		pos = temp.find("|", pos);
	}
	$$.code = strdup(temp.c_str());
    }
    | WRITE vars
    {
    	std::string temp;
	temp.append($2.code);
	size_t pos = temp.find("|", 0);
	
	while (pos != std::string::npos) {
		temp.replace(pos, 1, ">");
		pos = temp.find("|", pos);
	}
	$$.code = strdup(temp.c_str());
    }
    | CONTINUE
    {
    	$$.code = strdup("continue\n");
    }
    | RETURN expression
    {
    	std::string temp;
	temp.append($2.code);
	temp.append("ret ");
	temp.append($2.place);
	temp.append("\n");
	$$.code = strdup(temp.c_str());
    }
    ;
	
bool_expr: relation_and_expr
    {
        $$.code = strdup($1.code);
        $$.place = strdup($1.place);
    }
    | relation_and_expr OR bool_expr
    {
        std::string temp;
        std::string dst = new_temp();
        temp.append($1.code);
        temp.append($3.code);
        temp += ". " + dst + "\n";
        temp += "|| " + dst + ", ";
        temp.append($1.place);
        temp.append(", ");
        temp.append($3.place);
        temp.append("\n");
        $$.code = strdup(temp.c_str());
        $$.place = strdup(dst.c_str());
    }
    ;
    
relation_and_expr: relation_expr /*dont*/
    {
    	$$.code = strdup($1.code);
        $$.place = strdup($1.place);
    }   
    | relation_expr AND relation_and_expr
    {
    	std::string temp;
	std::string dst = new_temp();
	$$.code = strdup($1.code);
	$$.place = strdup($3.place);
        temp += ". " + dst + "\n";
        temp += "&& " + dst + ", ";
        temp.append($1.place);
        temp.append(", ");
        temp.append($3.place);
        temp.append("\n");
        $$.code = strdup(temp.c_str());
        $$.place = strdup(dst.c_str());
    }
    ;
    
relation_expr: expression comp expression /*done*/
    {
        std::string dst = new_temp();
        std::string temp;
        temp.append($1.code);
        temp.append($3.code);
        temp += ". " + dst + "\n" + $2.place + dst + ", " + $1.place + ", " + $3.place + "\n";
        $$.code = strdup(temp.c_str());
        $$.place = strdup(dst.c_str());
    }
    | NOT TRUE 
    {
        std::string temp;
        temp.append("0");
        $$.code = strdup("");
        $$.place = strdup(temp.c_str());
    }
    | NOT FALSE 
    {
        std::string temp;
        temp.append("1");
        $$.code = strdup("");
        $$.place = strdup(temp.c_str());
    }
    | NOT expression comp expression
    {
        std::string dst = new_temp();
	std::string dst2 = new_temp();
        std::string temp;
        temp.append($2.code);
        temp.append($4.code);
        temp += ". " + dst + "\n" + $3.place + dst + ", " + $2.place + ", " + $4.place + "\n";
	temp += ". " + dst2 + "\n" + "! " + dst2 + ", " + dst + "\n";
        $$.code = strdup(temp.c_str());
        $$.place = strdup(dst.c_str());
    }
    | NOT L_PAREN bool_expr R_PAREN
    {
    	std::string dst = new_temp();
        std::string temp;
        temp.append($3.code);
	temp += ". " + dst + "\n" + "! " + dst + ", " + $3.place + "\n";
        $$.code = strdup(temp.c_str());
        $$.place = strdup(dst.c_str());
    }
    | TRUE
    {
        std::string temp;
        temp.append("1");
        $$.code = strdup("");
        $$.place = strdup(temp.c_str());
    }
    | FALSE
    {
        std::string temp;
        temp.append("0");
        $$.code = strdup("");
        $$.place = strdup(temp.c_str());
    }
    | L_PAREN bool_expr R_PAREN
    {
        $$.code = strdup($2.code);
        $$.place = strdup($2.place);
    }
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
expressions: expression
    {
	std::string temp;
	temp.append($1.code);
	temp.append("param ");
	temp.append($1.place);
	temp.append("\n");
	$$.code = strdup(temp.c_str());
	$$.place = strdup("");
    }
    | expression COMMA expressions
    {
    	std::string temp;
	temp.append($1.code);
	temp.append("param ");
	temp.append($1.place);
	temp.appned("\n");
	temp.append($3.code);
	$$.code = strdup(temp.c_str());
	$$.place = strdup("");
     }
     ;
	
	
/*MULTIPLICATIVE-EXPR*/	//NOT COMPLETE
multiplicative_expr: Term MULT multiplicative_expr
    {
	std::string temp;
	std::string dst = new_temp();
	temp.append($1.code);
	temp.append($3.code);
	temp.append(". ");
	
	
	
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
