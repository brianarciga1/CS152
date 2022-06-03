%{
    #define YY_NO_INPUT
    #include <stdio.h>
    #include <stdlib.h>
    #include <map>
    #include <string.h>
    #include <set>

int tempCount = 0;
int labelCount = 0;
extern char* yytext;
extern int num_columns;
std::map<std::string, std::string> varTemp;
std::map<std::string, int> arrSize;
bool mainFunc = false;
std::set<std::string> funcs;
std::set<std::string> reserved{"NUMBER", "IDENT", "RETURN", "FUNCTION", "SEMICOLON", "BEGINPARAMS", "ENDPARAMS", "BEGINLOCALS", "ENDLOCALS", "BEGINBODY", "ENDBODY", "BEGINLOOP", "ENDLOOP", "COLON", "INTEGER",
    "COMMA", "ARRAY", "L_SQUARE_BRACKET", "R_SQUARE_BRACKET", "L_PAREN", "R_PAREN", "IF", "ELSE", "THEN", "CONTINUE", "ENDIF", "OF", "READ", "WRITE", "DO", "WHILE", "FOR", "TRUE", "FALSE", "ASSIGN", "EQ", "NEQ",
    "LT", "LTE", "GT", "GTE", "ADD", "SUB", "MULT", "DIV", "MOD", "AND", "OR", "NOT", "function", "functions", "declaration", "declarations", "var", "vars", "expression", "expressions", "Ident", 
    "bool_expr", "relation_and_expr", "relation_and_inv", "relation_expr", "comp", "multiplicative-expr", "term", "statement", "statements"};
void yyerror(const char* s);
int yylex();
std::string new_temp();
std::string new_label();
%}

%union{
    int num_val;
    char * id_val;
    struct S{
        char* code;
    } statement;
    struct E{
        char* place;
        char *code;
        bool arr;
    } expression;
}
%error-verbose
%start Program
%token FUNCTION BEGINPARAMS ENDPARAMS BEGINLOCALS ENDLOCALS BEGINBODY ENDBODY INTEGER ARRAY ENUM OF IF THEN ENDIF ELSE WHILE FOR DO BEGINLOOP ENDLOOP CONTINUE READ WRITE TRUE FALSE SEMICOLON COLON COMMA L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET ASSIGN RETURN
%token <id_val> IDENT
%token <num_val> NUMBER
%type <expression> function declarations declaration vars var expressions expression Ident FuncIdent
%type <expression> bool_expr relation_and_expr relation_expr_inv relation_expr comp multiplicative-expr term
%type <statement> statements statement
%right ASSIGN
%left OR
%left AND
%right NOT
%left LT LTE GT GTE EQ NEQ
%left ADD SUB
%left MULT DIV MOD
%%

/*prog_start: functions { printf("prog_start -> functions\n");}
        ;*/

/*99% of our errors are for the same reason. The $ isn't recognized, something about having "no delcared type". <--------------------------------------*/
Program:    %empty
    {
        if (!mainFunc){
            printf("No main function was declared\n");
        }
    }
    | function Program
    {
    }
    ;

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
        if(statements.find("continue") != std::string::npos){
            printf("Error: Continue outside loop in function %s\n", $2.place);
        }
        temp.append(statements);
        temp.append("endfunc\n\n");
        printf(temp.c_str());
    }
    ;
        

declarations: %empty{ 
                /*printf("declarations -> epsilon\n");*/
                $$.place = strdup("");
                $$.code = strdup("");
                }
            | declaration SEMICOLON declarations {
                /*printf("declarations -> declaration SEMICOLON declarations\n");*/
                std::string temp;
                temp.append($1.code);
                temp.append($3.code);
                $$.code = strdup(temp.c_str());
                $$.place=strdup("");
                }
            ;

declaration: Ident COLON INTEGER
    {
        int left = 0;
        int right = 0;
        std::string parse($1.place);
        std::string temp;
        bool ex = false;
        while(!ex){
            right = parse.find("|", left);
            temp.append(".");
            if(right == std::string::npos){
                std::string ident = parse.substr(left, right);
                if(reserved.find(ident) != reserved.end()){
                    printf("Identifier %s's name is a reserved word, can't be used.\n", ident.c_str());
                }
                if(funcs.find(ident) != funcs.end() || varTemp.find(ident) != varTemp.end()){
                    printf("Identifier %s is previously declared.\n", ident.c_str());
                }
                else{
                    varTemp[ident] = ident;
                    arrSize[ident] = 1;
                }
                temp.append(ident);
                ex = true;
            }
            else{
                std::string ident = parse.substr(left, right - left);
                if(reserved.find(ident) != reserved.end()){
                    printf("Identifier %s's name is a reserved word, can't be used.\n", ident.c_str());
                }
                if(funcs.find(ident) != funcs.end() || varTemp.find(ident) != varTemp.end()){
                    printf("Identifier %s is previously declared.\n", ident.c_str());
                }
                else{
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
        while(!ex){
            right = parse.find("|", left);
            temp.append(".[]");
            if(right == std::string::npos){
                std::string ident = parse.substr(left, right);
                if(reserved.find(ident) != reserved.end()){
                    printf("Identifier %s's name is a reserved word, can't be used.\n", ident.c_str());
                }
                if(funcs.find(ident) != funcs.end() || varTemp.find(ident) != varTemp.end()){
                    printf("Identifier %s is previously declared.\n", ident.c_str());
                }
                else{
                    if($5 <= 0){
                        printf("Declaring array ident %s of size <= 0.\n", ident.c_str());
                    }
                    varTemp[ident] = ident;
                    arrSize[ident] = $5;
                }
                temp.append(ident);
                ex = true;
            }
            else{
                std::string ident = parse.substr(left, right - left);
                if(reserved.find(ident) != reserved.end()){
                    printf("Identifier %s's name is a reserved word, can't be used.\n", ident.c_str());
                }
                if(funcs.find(ident) != funcs.end() || varTemp.find(ident) != varTemp.end()){
                    printf("Identifier %s is previously declared.\n", ident.c_str());
                }
                else{
                    if($5 <= 0){
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
        
statements: statement SEMICOLON statements
    {
        std::string temp;
        temp.append($1.code);
        temp.append($3.code);
        $$.code = strdup(temp.c_str());
    }
    | statement SEMICOLON
    {
        $$.code = strdup($1.code);
    }
    ;
        
statement: var ASSIGN expression
    {
        std::string temp;
        temp.append($1.code);
        temp.append($3.code);
        std::string mid = $3.place;
        if($1.arr && $3.arr){
            temp += "[]= ";
        }
        else if($1.arr){
            temp += "[]= ";
        }
        else if($3.arr){
            temp += "[]= ";
        }
        else{
            temp += "= ";
        }
        temp.append($1.place);
        temp.append(", ");
        temp.append(mid);
        temp += "\n";
        $$.code = strdup(temp.c_str());
    }
    | IF bool_expr THEN statements ENDIF
    {
        std::string s1 = new_label();
        std::string s2 = new_label();
        std::string temp;
        temp.append($2.code);
        temp = temp + "?:= " + s1 + ", " + $2.place + "\n";
        temp = temp + ":= " + s2 + "\n";
        temp = temp + ": " + s1 + "\n";
        temp.append($4.code);
        temp = temp + ": " + s2 + "\n";
        $$.code = strdup(temp.c_str());
    }
    | IF  bool_expr THEN statements ELSE statements ENDIF
    {
        std::string s1 = new_label();
        std::string s2 = new_label();
        std::string temp;
        temp.append($2.code);
        temp = temp + "?:= " + s1 + ", " + $2.place + "\n";
        temp.append($6.code);
        temp = temp + ":= " + s2 + "\n";
        temp = temp + ": " + s1 + "\n";
        temp.append($4.code);
        temp = temp + ": " + s2 + "\n";
        $$.code = strdup(temp.c_str());
    }
    |  WHILE bool_expr BEGINLOOP statements ENDIF
    {
        std::string s1 = new_label();
        std::string s2 = new_label();
        std::string s3 = new_label();
        std::string temp = $4.code;
        std::string temp2;
        size_t pos = temp.find("continue");
        while(pos != std::string::npos){
            temp.replace(pos, 8, ":= " + s1);
            pos = temp.find("continue");
        }

        temp2.append(": ");
        temp2 += s1 + "\n";
        temp2.append($2.code);
        temp2 += "?:= " + s2 + ", ";

        temp2.append($2.place);
        temp2.append("\n");
        temp2 += ":= " + s3 + "\n";
        temp2 += ": " + s2 + "\n";
        temp2.append(temp);
        temp2 += ":= " + s1 + "\n";
        temp2 += ": " + s2 + "\n";
        $$.code = strdup(temp2.c_str());
    }
    | DO BEGINLOOP statements ENDLOOP WHILE bool_expr
    {
        std::string s1 = new_label();
        std::string s2 = new_label();
        std::string temp = $3.code;
        std::string temp2;
        size_t pos = temp.find("continue");
        while(pos != std::string::npos){
            temp.replace(pos, 8, ":= " + s2);
            pos = temp.find("continue");
        }
        temp2.append(": ");
        temp2 += begin + "\n";
        temp2.append(temp);
        temp2 += ": " + s2 + "\n";
        temp2.append($6.code);
        temp2 += "?:= " + s1 + ", ";
        temp2.append($6.place);
        temp2.append("\n");
        $$.code = strdup(temp.c_str());
    }
    | FOR vars ASSIGN NUMBER SEMICOLON bool_expr SEMICOLON vars ASSIGN expression BEGINLOOP statements ENDLOOP
    {
        std::string temp;
        std::string dst=new_temp();
        std::string condition = new_label();
        std::string inner = new_label();
        std::string after = new_label();
        std::string code = $12.code;
        size_t pos = code.find("continue");
        while(pos!=std::string::npos){
            code.replace(pos, $8, ":= "+"increment"); /*changed this -W*/
            pos= code.find("continue");
        }
        temp.append($2.code);
        std::string mid = std::to_string($4);
        if($2.arr){
            temp+="[]= ";
        }
        else{
            temp +="= ";
        }
        temp.append($2.place);
        temp.append(", ");
        temp.append(mid);
        temp+="\n ";
        temp+=": " +condition+ "\n";
        temp.append($6.code);
        temp += "?:= "+inner + ", ";
        temp.append($6.place);
        temp.append("\n");
        temp +=":= "+after+"\n";
        temp +=": " + inner +"\n";
        temp.append(code);
        temp += ": " + increment + "\n";
        temp.append($8.code);
        temp.append($10.code);
        if($8.arr){
            temp+="[]= ";
        }
        else{
            temp+="= ";
        }
        temp.append($8.place);
        temp.append(", ");
        temp.append($10.place);
        temp += "\n";
        temp += ":= " + condition + "\n";
        temp += ": " + after + "\n";
        $$.code = strdup(temp.c_str());
    }
    | READ vars
    {
        std::string temp;
        temp.append($2.code);
        size_t pos = temp.find("|", 0);
        while(pos != std::string::npos) {
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

        while(pos != std::string::npos) {
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


relation_and_expr: relation_expr_inv AND relation_and_expr
    {
        std::string dst = new_temp();
        std::string temp;
        temp.append($1.code);
        temp.append($3.code);
        temp += ". " + dst + "\n" + "&& " + dst + ", " + $1.place + ", " + $3.place + "\n";
        $$.code = strdup(temp.c_str());
        $$.place = strdup(dst.c_str());
    }
    | relation_expr_inv
    {
        $$.code = strdup($1.code);
        $$.place = strdup($1.place);
    }
    ;
    
relation_expr_inv: NOT relation_expr_inv
    {
        std::string dst = new_temp();
        std::string temp;
        temp.append($2.code);
        temp += ". " + dst + "\n" + "! " + dst + ", " + $2.place + "\n";
        $$.code = strdup(temp.c_str());
        $$.place = strdup(dst.c_str());
    }
    | relation_expr
    {
        $$.code = strdup($1.code);
        $$.place = strdup($1.place);
    }
    ;
relation_expr: expression comp expression
    {
        std::string dst = new_temp();
        std::string temp;
        temp.append($1.code);
        temp.append($3.code);
        temp += ". " + dst + "\n" + $2.place + dst + ", " + $1.place + ", " + $3.place + "\n";
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

Ident: IDENT
    {
        $$.place = strdup($1);
        $$.code = strdup("");
    }
    ;
    
/*Idents: Ident
    {
        $$.place = strdup($1);
        $$.code = strdup("");
    }
    | Ident COMMA Idents
    {
        std::string temp;
        temp.append($1.place);
        temp.append("|");
        temp.append($3.place);
        $$.place = strdup(temp.c_str());
        $$.code = strdup("");
    }
    ; */

FuncIdent: IDENT
    {
        if (funcs.find($1) != funcs.end()){
            printf("function name %s already declared.\n", $1);
        }
        else{
            funcs.insert($1);
        }
    $$.place = strdup($1);
    $$.code = strdup("");
    }
    ;

comp: EQ
    {
        $$.place = strdup("");
        $$.code = strdup("== ");
    }
    | NEQ
    {
        $$.place = strdup("");
        $$.code = strdup("!= ");
    }
    | LT
    {
        $$.place = strdup("");
        $$.code = strdup("< ");
    }
    | LTE
    {
        $$.place = strdup("");
        $$.code = strdup("<= ");
    }
    | GT
    {
        $$.place = strdup("");
        $$.code = strdup("> ");
    }
    | GTE
    {
        $$.place = strdup("");
        $$.code = strdup(">= ");
    }
    ;   

expressions: expression COMMA expressions 
            {
                std::string temp;
                temp.append($1.code);
                temp.append("param ");
                temp.append($1.place);
                temp.append("\n");
                temp.append($3.code);   /* I think this is sufficient, but not totally sure*/
                $$.code=strdup(temp.c_str());
                $$.place=strdup(temp.c_str());
            }
            | expression {
                std::string temp;
                temp.append("param ");
                temp.append($1.place);
                temp.append("\n");
                $$.code=strdup(temp.c_str());
                $$.place=strdup(temp.c_str());
            }
            ;

expression: multiplicative-expr {printf("expression -> multiplicative-expr\n");}
            | multiplicative-expr ADD multiplicative-expr {
                std::string temp;
                std::string dst= new_temp();
                temp.append($1.code);
                temp.append($3.code);
                temp+=". " + dst + "\n";
                temp+= "+ " + dst + ", ";
                temp.append($1.place);
                temp+=", ";
                temp.append($3.place);
                temp+="\n";
                $$.code = strdup(temp.c_str());
                $$.place = strdup(dst.c_str());

            }
            | multiplicative-expr SUB multiplicative-expr {
                std::string temp;
                std::string dst= new_temp();
                temp.append($1.code);
                temp.append($3.code);
                temp+=". " + dst + "\n";
                temp+= "- " + dst + ", ";
                temp.append($1.place);
                temp+=", ";
                temp.append($3.place);
                temp+="\n";
                $$.code = strdup(temp.c_str());
                $$.place = strdup(dst.c_str());

            }
            ;
multiplicative-expr: term {
                    std::string temp;
                    temp.append($1.code);
                    temp.append($1.place);
                    temp.append("\n");
                    $$.code = strdup(temp.c_str());
                    $$.place = strdup(""); /*went freeballing here, might need fixing*/
                    }
                    | term MULT multiplicative-expr {
                        std::string temp;
                        std::string dst = new_temp();
                        temp.append($1.code);
                        temp.append($3.code);
                        temp.append(". ");
                        temp.append(dst);
                        temp.append("\n");
                        temp +="* " + dst + ", ";
                        temp.append($1.place);
                        temp+=", ";
                        temp.append($3.place);
                        temp+="\n";
                        $$.code = strdup(temp.c_str());
                        $$.place = strdup(dst.c_str());
                    }
                    | term DIV multiplicative-expr {
                        std::string temp;
                        std::string dst = new_temp();
                        temp.append($1.code);
                        temp.append($3.code);
                        temp.append(". ");
                        temp.append(dst);
                        temp.append("\n");
                        temp +="/ " + dst + ", ";
                        temp.append($1.place);
                        temp+=", ";
                        temp.append($3.place);
                        temp+="\n";
                        $$.code = strdup(temp.c_str());
                        $$.place = strdup(dst.c_str());
                    }
                    | term MOD multiplicative-expr {
                        std::string temp;
                        std::string dst = new_temp();
                        temp.append($1.code);
                        temp.append($3.code);
                        temp.append(". ");
                        temp.append(dst);
                        temp.append("\n");
                        temp +="% " + dst + ", ";
                        temp.append($1.place);
                        temp+=", ";
                        temp.append($3.place);
                        temp+="\n";
                        $$.code = strdup(temp.c_str());
                        $$.place = strdup(dst.c_str());
                    }
                    ;

term: SUB var 
    {
        std::string dst=new_temp();
        std::string temp;
        if($2.arr){
             temp.append($2.code);
             temp.append(". ");
            temp.append(dst);
            temp.append("\n");
            temp += "=[] " + dst + ", ";
            temp.append($2.place);
            temp.append("\n");
        }
        else{
            temp.append(". ");
            temp.append(dst);
            temp.append("\n");
            temp += "= " + dst + ", ";
            temp.append($2.place);
            temp.append("\n");
            temp.append($2.code);
        }
        if(varTemp.find($2.place) != varTemp.end()){
            varTemp[$2.place]=dst;
        }
        temp +="* " + dst + ", "+dst + ", -1\n";
        $$.code = strdup(temp.c_str());
        $$.place=strdup(temp.c_str());
    }
    | SUB NUMBER {
        std::string dst = new_temp();
        std::string temp;
        temp.append(". ");
        temp.append(dst);
        temp.append("/n");
        temp= temp + "= " + dst +", -" + std::to_string($2) + "\n";
        $$.code = strdup(temp.c_str());
        $$.place = strdup(dst.c_str());
    }
    | SUB L_PAREN expression R_PAREN { 
        std::string temp;
        temp.append($3.code);
        temp.append("* ");
        temp.append($3.place);
        temp.append(", ");
        temp.append($3.place);
        temp.append(", -1\n");
        $$.code = strdup(temp.c_str());
        $$.place = strdup($3.place);
    }
    | var {
        std::string dst = new_temp();
    std::string temp;
        if($1.arr){
            temp.append($1.code);
            temp.append(". ");
            temp.append(dst);
            temp.append("\n");
            temp.append("=[] ");
            temp.append(dst);
            temp.append(", ");
            temp.append($1.place);
            temp.append("\n");
        }
        else{
            temp.append(". ");
            temp.append(dst);
            temp.append("\n");
            temp.append("= ");
            temp.append(dst);
            temp.append(", ");
            temp.append($1.place);
            temp.append("\n");
        }
        if(varTemp.find($1.place)!=varTemp.end()){
            varTemp[$1.place]=dst;
        }
        $$.code = strdup(temp.c_str());
        $$.place = strdup(dst.c_str());
    } 
    | NUMBER {
        std::string dst = new_temp();
        std::string temp;
        temp.append(". ");
        temp.append(dst);
        temp.append("/n");
        temp= temp + "= " + dst +", " + std::to_string($1) + "\n";
        $$.code = strdup(temp.c_str());
        $$.place = strdup(dst.c_str());
    }
    | L_PAREN expression R_PAREN {
        $$.code = strdup($2.code);
        $$.place = strdup($2.place);
    }
    /*| IDENT L_PAREN expression R_PAREN {printf("term -> IDENT L_PAREN expression R_PAREN\n");} Dont think this is needed*/
    | Ident L_PAREN expressions R_PAREN {
        std::string temp;
        std::string func = $1.place;
        if(funcs.find(func)==funcs.end()){
            printf("Calling undeclared function %s.\n", func.c_str());
        }
        std::string dst= new_temp();
        temp.append($3.code);
        temp+=". " + dst +"\ncall ";
        temp.append($1.place);
        temp += ", " + dst + "\n";
        $$.code = strdup(temp.c_str());
        $$.place = strdup(dst.c_str());
    }
    ;
vars: var
    {
        std::string temp;
        temp.append($1.code);
        if($1.arr){
            temp.append(".[]| ");
        }
        else{
            temp.append(".| ");
        }
        temp.append($1.place);
        temp.append("\n");
        $$.code = strdup(temp.c_str());
        $$.place = strdup("");
    }
    | var COMMA vars
    {
        std::string temp;
        temp.append($1.code);
        if($1.arr){
            temp.append(".[]| ");
        }
        else{
            temp.append(".| ");
        }
        temp.append($1.place);
        temp.append("\n");
        temp.append($3.place);
        $$.code = strdup(temp.c_str());
        $$.place = strdup("");
    };

var: Ident {
    
    std::string temp;
    std::string ident=$1.place;
    if(funcs.find(ident) == funcs.end() && varTemp.find(ident)==varTemp.end()){
        printf("Identifier %s is not declared.\n",ident.c_str());
    }
    else if(arrSize[ident]>1){
        printf("Did not provide index for array Identifier %s.\n", ident.c_str());
    }
    $$.code = strdup("");
    $$.place=strdup(ident.c_str());
    $$.arr = false;
    }
    | Ident L_SQUARE_BRACKET expression R_SQUARE_BRACKET {
        std::string temp;
        std::string ident = $1.place;
        if(funcs.find(ident) == funcs.end() && varTemp.find(ident) == varTemp.end()){
            printf("Identifier %s is not declared.\n", ident.c_str());
        }
        else if(arrSize[ident] == 1){
            printf("Provided index for non-array Identifier %s.\n", ident.c_str());
        }
        temp.append($1.code);
        temp.append(", ");
        temp.append($3.place);
        $$.code = strdup($3.code);
        $$.place = strdup(temp.c_str());
        $$.arr = true;
    }
    ;
    
%%

void yyerror(const char* s)
{
    extern int yylineno;
    extern char *yytext;

        printf("%s on line %d at char %d at symbol \"%s\"\n", s, yylineno, num_columns, yytext);
        exit(1);
}


std::string new_temp(){
    std::string t= "t" + std::to_string(tempCount);
    tempCount++;
    return t;
}

std::string new_label(){
    std::string l="L" + std::to_string(labelCount);
    labelCount++;
    return l;
}


int main(int argc, char ** argv) {
    if(argc > 1) {
        yyin = fopen(argv[1], "r");
        if(yyin == NULL){
            printf("syntax: %s filename", argv[0]);
        }
    }
    yyparse();
    return 0;
}
void yyerror(const char *msg) {
    printf("Error: Line %d, position %d: %s \n", num_lines, num_columns, msg);
}
