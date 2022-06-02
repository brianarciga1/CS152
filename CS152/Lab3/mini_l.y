%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <map>
    #include <set>
    void yyerror(const char* msg);
    extern int currLine;
    extern int currPos;
    bool mainExists = false;
    int numTemp = 0;
    int numLabel = 0;
    extern FILE* yyin;

    unsigned int tempCount = 0;
    unsigned int labelCount = 0;

    std::map<std::string, std::string> varTemp;
    std::map<std::string, int> arrSize;
    std::set<std::string> funcs;
    std::set<std::string> reserved { "NUMBER", "IDENT", "RETURN" }; // TODO LIST OF RESERVED KEYWORDS

    int yylex();
    std::string new_temp();
    std::string new_label();
%}

%union{
    int num_val;
    char* id_val;
    struct S {
            char* code;
    }   statement;
    struct E {
            char* place;
            char* code;
            bool arr;
    }   expression;
}

%error-verbose
%start program
%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY ENUM OF IF THEN ENDIF ELSE WHILE DO BEGINLOOP ENDLOOP CONTINUE READ WRITE TRUE FALSE RETURN SEMICOLON COLON COMMA L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET ASSIGN
%token <id_val> IDENT
%token <num_val> NUMBER
%type <expression> function funcident declarations declaration var vars expression identifiers chained_exprs relation_expr
%type <expression> boolexpr relation_and_expr multiplicative_expr optional_exprs comp term
%type <statement> statement repeatedstmts elsestmt chainedstmts
%left ADD MINUS
%left EQ NEQ GT GTE LT LTE
%right NOT
%left AND OR
%right ASSIGN
%left MULT DIV MOD

%%
program: functions                                              {;}
        ;
functions:                                                      
        {
                if (!mainExists) {
                        printf("No main function declared!\n");
                }
        }
        | function functions                                    
        ;
function: FUNCTION funcident SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY repeatedstmts END_BODY  
                {
                        std::string ftemp = "func ";

                        ftemp.append($2.place);
                        ftemp.append("\n");
                        std::string s = $2.place;
                        if (s == "main") {
                                mainExists = true;
                        }

                        ftemp.append($5.code);
                        std::string decs = $5.code;
                        int numDec = 0;
                        while (decs.find(".") != std::string::npos) {
                                int pos = decs.find(".");
                                decs.replace(pos, 1, "=");
                                std::string part = ", $" + std::to_string(numDec) + "\n";
                                numDec++;
                                decs.replace(decs.find("\n", pos), 1, part);
                        }
                        ftemp.append(decs);

                        ftemp.append($8.code); 
                        std::string statements = $11.code;
                        if (statements.find("continue") != std::string::npos) {
                                printf("ERROR: Continue outside loop in function %s\n", $2.place);
                        }
                        ftemp.append(statements);
                        ftemp.append("endfunc\n\n");
                        printf(ftemp.c_str());
                }
        ;

funcident: IDENT
         {
                 std::string func_name = strdup($1);
                 if (funcs.find(func_name) != funcs.end()) {
                        printf("Function %s is previously declared!\n", func_name.c_str());
                 }
                 else {
                     funcs.insert(func_name);    
                 }
                 $$.place = strdup(func_name.c_str());
                 $$.code = strdup("");
         }
           ;
declarations: {
           $$.place = strdup("");
           $$.code = strdup("");
        }
        | declaration SEMICOLON declarations
        {
           std::string temp;
           temp.append($1.code);
           temp.append($3.code);
           $$.code = strdup(temp.c_str());
           $$.place = strdup("");
        }
        ;
repeatedstmts: statement SEMICOLON chainedstmts                 
        {
                std::string stemp;
                stemp.append($1.code);
                stemp.append($3.code);

                $$.code = strdup(stemp.c_str());
        }
        ;
chainedstmts: {
                $$.code = strdup("");  
        }                        
        | statement SEMICOLON chainedstmts                      
        {
                std::string stemp;
                stemp.append($1.code);
                stemp.append($3.code);

                $$.code = strdup(stemp.c_str());
        }
        ;
declaration: identifiers COLON INTEGER
        {
          int left = 0;
          int right = 0;
          std::string parse($1.place);
          std::string temp;

          bool ex = false;
          while (!ex) {
                right = parse.find("|", left);
                temp.append(". ");
                if (right == std::string::npos) {
                        std::string ident = parse.substr(left, right);
                        if (reserved.find(ident) != reserved.end()) {
                                printf("Identifier %s's name is a reserved word.\n", ident.c_str());
                        }
                        if (funcs.find(ident) != funcs.end() || varTemp.find(ident) != varTemp.end()) {
                                printf("Identifier %s is previously declared!\n", ident.c_str());
                        } else {
                                varTemp[ident] = ident;
                                arrSize[ident] = 1;
                        }
                        temp.append(ident);
                        ex = true;
                } else {
                        std::string ident = parse.substr(left, right - left);
                        if (reserved.find(ident) != reserved.end()) {
                                printf("Identifier %s's name is a reserved word!\n", ident.c_str());
                        } 
                        if (funcs.find(ident) != funcs.end() || varTemp.find(ident) != varTemp.end()) {
                                printf("Identifier %s is previously declared!\n", ident.c_str());
                        } else {
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
        | identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER
        {
          int left = 0;
          int right = 0;
          std::string parse($1.place);
          std::string temp;

          bool ex = false;
          while (!ex) {
                right = parse.find("|", left);
                temp.append(".[] ");
                if (right == std::string::npos) {
                        std::string ident = parse.substr(left, right);
                        if (reserved.find(ident) != reserved.end()) {
                                printf("Identifier %s's name is a reserved word.\n", ident.c_str());
                        }
                        if (funcs.find(ident) != funcs.end() || varTemp.find(ident) != varTemp.end()) {
                                printf("Identifier %s is previously declared!\n", ident.c_str());
                        } else {
                                if ($5 <= 0) {
                                        printf("Declaring array ident %s of size <= 0\n", ident.c_str());
                                } 
                                varTemp[ident] = ident;
                                arrSize[ident] = $5;
                        }
                        temp.append(ident);
                        ex = true;
                } else {
                        std::string ident = parse.substr(left, right - left);
                        if (reserved.find(ident) != reserved.end()) {
                                printf("Identifier %s's name is a reserved word!\n", ident.c_str());
                        } 
                        if (funcs.find(ident) != funcs.end() || varTemp.find(ident) != varTemp.end()) {
                                printf("Identifier %s is previously declared!\n", ident.c_str());
                        } else {
                                if ($5 <= 0) {
                                        printf("Declaring array ident %s of size <= 0\n", ident.c_str());
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
                $$.code = strdup(temp.c_str());
                $$.place = strdup("");      
          }
        }    
        | identifiers COLON ENUM L_PAREN identifiers R_PAREN { printf("declaration -> identifiers COLON ENUM L_PAREN identifiers R_PAREN\n"); }
        ;

identifiers: IDENT
        {
                $$.place = strdup($1);
                $$.code = strdup("");
        }
        | IDENT COMMA identifiers
        {
                std::string temp;
                temp.append($1);
                temp.append("|");
                temp.append($3.place);

                $$.place = strdup(temp.c_str());
                $$.code = strdup("");
        }
        ;

statement: var ASSIGN expression                                
        {
                std::string temp;
                temp.append($1.code);
                temp.append($3.code);
                std::string mid = $3.place;
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
                temp.append(mid);
                temp += "\n";
                
                $$.code = strdup(temp.c_str());
        }
        | IF boolexpr THEN repeatedstmts elsestmt ENDIF
        {
                std::string ifS = new_label();
                std::string after = new_label();
                std::string temp;
                std::string etemp = strdup($5.code);

                temp.append($2.code);
                temp = temp + 
                        "?:= " + ifS + ", " + $2.place + "\n";   // true, jump ifS and do from $4
                if (etemp != "") {
                        temp.append(etemp);     // else reaches if not jumped (false)
                }
                temp = temp +
                        ":= " + after + "\n";   // if not true, jumps to label (skips if, else is ran already)
                temp = temp + 
                        ": " + ifS + "\n";

                temp.append($4.code);
                temp = temp +
                        ": " + after + "\n";
                $$.code = strdup(temp.c_str());
        }
        | WHILE boolexpr BEGINLOOP repeatedstmts ENDLOOP        
        {
                std::string whileIf = new_label();      // while if (bool) label
                std::string whileS = new_label();       // while start label
                std::string after = new_label();
                std::string temp;
                std::string code = $4.code;
                size_t pos = code.find("continue");
                while (pos != std::string::npos) {
                        code.replace(pos, 8, ":= " + whileIf + "\n");
                        pos = code.find("continue");
                }

                temp = temp + 
                        ": " + whileIf + "\n";
                temp.append($2.code);
                temp = temp + 
                        "?:= " + whileS + ", " + $2.place + "\n";   // true, jump whileS and do from $4
                temp = temp +
                        ":= " + after + "\n";   // if not true, jumps to after
                temp = temp + 
                        ": " + whileS + "\n";

                temp.append(code);
                temp = temp + 
                        ":= " + whileIf + "\n";
                temp = temp +
                        ": " + after + "\n";
                $$.code = strdup(temp.c_str());
        }
        | DO BEGINLOOP repeatedstmts ENDLOOP WHILE boolexpr     
        {
                std::string doS = new_label();  // do while's start
                std::string doIf = new_label(); // do while's if 
                std::string temp;
                std::string code = $3.code;
                size_t pos = code.find("continue");
                while (pos != std::string::npos) {
                        code.replace(pos, 8, ":= " + doIf + "\n");     // jump to if statement
                        pos = code.find("continue");
                }

                temp = temp + 
                        ": " + doS + "\n";
                temp.append(code);
                temp = temp +
                        ": " + doIf + "\n";
                temp.append($6.code);
                temp = temp + 
                        "?:= " + doS  + ", " + $6.place + "\n";
                $$.code = strdup(temp.c_str());
        }
        | READ vars
        {
          std::string parse($2.code);
          size_t pos = parse.find("|");
          while (pos != std::string::npos) {
                parse.replace(pos, 1, "<");
                pos = parse.find("|");
          }
          $$.code = strdup(parse.c_str());      
        }
        | WRITE vars
        {
          std::string parse($2.code);
          size_t pos = parse.find("|");
          while (pos != std::string::npos) {
                parse.replace(pos, 1, ">");
                pos = parse.find("|");
          }
          $$.code = strdup(parse.c_str());         
        }
        | CONTINUE
        {
                std::string temp = "continue";
                $$.code = strdup(temp.c_str());
        }
        | RETURN expression
        {
                std::string temp;
                temp.append($2.code);
                temp += "ret ";
                temp.append($2.place);
                temp.append("\n");

                $$.code = strdup(temp.c_str());      
        }
        ;
elsestmt: {
                $$.code = strdup("");
        }
        | ELSE repeatedstmts
        {
                $$.code = strdup($2.code);
        }
        ;
vars: var COMMA vars
      {
              std::string temp;
              temp.append($1.code);
              temp.append($1.arr ? ".[]| " : ".| ");
              temp.append($1.place);
              temp.append("\n");
              temp.append($3.code);
              $$.code = strdup(temp.c_str());
              $$.place = strdup("");
      }  
      | var
      {
              std::string temp;
              temp.append($1.code);
              temp.append($1.arr ? ".[]| " : ".| ");
              temp.append($1.place);
              temp.append("\n");

              $$.code = strdup(temp.c_str());
              $$.place = strdup("");
      }
      ;

boolexpr: relation_and_expr                     
        {
                std::string temp;

                $$.code = strdup($1.code);
                $$.place = strdup($1.place);
        }
        | relation_and_expr OR boolexpr
        {
                std::string temp;
                temp.append($1.code);
                temp.append($3.code);

                std::string dest = new_temp();
                temp += ". " + dest + "\n";
                temp += "|| ";
                temp.append(dest);
                temp += ", ";
                temp.append($1.place);
                temp += ", ";
                temp.append($3.place);
                temp.append("\n");

                $$.code = strdup(temp.c_str());
                $$.place = strdup(dest.c_str());
        }
        ;
relation_and_expr: relation_expr
                   {
                        std::string temp;

                        $$.code = strdup($1.code);
                        $$.place = strdup($1.place);
                   }
                   | relation_expr AND relation_and_expr
                   {
                        std::string temp;
                        temp.append($1.code);
                        temp.append($3.code);

                        std::string dest = new_temp();
                        temp += ". " + dest + "\n";
                        temp += "&& ";
                        temp.append(dest);
                        temp += ", ";
                        temp.append($1.place);
                        temp += ", ";
                        temp.append($3.place);
                        temp.append("\n");

                        $$.code = strdup(temp.c_str());
                        $$.place = strdup(dest.c_str());
                   }          
                   ;

relation_expr: NOT expression comp expression
               {
                       std::string dest = new_temp();
                       std::string dest2 = new_temp();
                       std::string temp;
                       
                       temp.append($2.code);
                       temp.append($4.code);
                       temp = temp + 
                                ". " + dest + "\n" + $3.place + dest + ", " + $2.place + ", " + $4.place + "\n";
                        temp = temp +
                                ". " + dest2 + "\n" + "! " + dest2 + ", " + dest + "\n";
                        $$.code = strdup(temp.c_str());
                        $$.place = strdup(dest2.c_str());
               }
               | NOT TRUE 
               {
                       $$.place = strdup("0");
                       $$.code = strdup("");
               }
               | NOT FALSE 
               {
                       $$.place = strdup("1");
                       $$.code = strdup("");
               }
               | NOT L_PAREN boolexpr R_PAREN                      
               {
                       std::string dest = new_temp();
                       std::string temp;

                        temp.append($3.code);
                        temp = temp +
                                ". " + dest + "\n" + "! " + dest + ", " + $3.place + "\n";

                       $$.place = strdup(dest.c_str());
                       $$.code = strdup(temp.c_str());
               } 
               | expression comp expression
               {
                       std::string dest = new_temp();
                       std::string temp;
                       
                       temp.append($1.code);
                       temp.append($3.code);
                       temp = temp + 
                                ". " + dest + "\n" + $2.place + dest + ", " + $1.place + ", " + $3.place + "\n";
                        $$.code = strdup(temp.c_str());
                        $$.place = strdup(dest.c_str());
               }
               | TRUE 
               {
                       $$.place = strdup("1");
                       $$.code = strdup("");
               }
               | FALSE 
               {
                       $$.place = strdup("0");
                       $$.code = strdup("");
               }
               | L_PAREN boolexpr R_PAREN
               {
                       $$.place = strdup($2.place);
                       $$.code = strdup($2.code);
               }    
               ;

comp: EQ 
        {
                $$.code = strdup("");
                $$.place = strdup("== ");
        }
      | NEQ 
        {
                $$.code = strdup("");
                $$.place = strdup("!= ");
        }
      | LT 
        {
                $$.code = strdup("");
                $$.place = strdup("< ");
        }
      | GT 
        {
                $$.code = strdup("");
                $$.place = strdup("> ");
        }
      | LTE 
        {
                $$.code = strdup("");
                $$.place = strdup("<= ");
        }
      | GTE 
        {
                $$.code = strdup("");
                $$.place = strdup(">= ");
        }
      ;  

expression: multiplicative_expr
            {
               $$.code = strdup($1.code);
               $$.place = strdup($1.place);     
            }    
            | multiplicative_expr ADD multiplicative_expr
            {
               std::string temp;
               std::string dest = new_temp();

               temp.append($1.code);
               temp.append($3.code);
               temp += ". " + dest + "\n";
               temp += "+ " + dest + ", ";
               temp.append($1.place);
               temp += ", ";
               temp.append($3.place);
               temp += "\n";

               $$.code = strdup(temp.c_str());
               $$.place = strdup(dest.c_str());
            }
            | multiplicative_expr MINUS multiplicative_expr 
            {
               std::string temp;
               std::string dest = new_temp();

               temp.append($1.code);
               temp.append($3.code);
               temp += ". " + dest + "\n";
               temp += "- " + dest + ", ";
               temp.append($1.place);
               temp += ", ";
               temp.append($3.place);
               temp += "\n";

               $$.code = strdup(temp.c_str());
               $$.place = strdup(dest.c_str());         
            }      
            ;    

multiplicative_expr: term
                     {
                        $$.code = strdup($1.code);     
                        $$.place = strdup($1.place);
                     }   
                     | term MULT term
                     {
                        std::string temp;
                        std::string dest = new_temp();

                        temp.append($1.code);
                        temp.append($3.code);
                        temp += ". " + dest + "\n";
                        temp += "* " + dest + ", ";
                        temp.append($1.place);
                        temp += ", ";
                        temp.append($3.place);
                        temp += "\n";

                        $$.code = strdup(temp.c_str());
                        $$.place = strdup(dest.c_str());      
                     }
                     | term DIV term
                     {
                        std::string temp;
                        std::string dest = new_temp();

                        temp.append($1.code);
                        temp.append($3.code);
                        temp += ". " + dest + "\n";
                        temp += "/ " + dest + ", ";
                        temp.append($1.place);
                        temp += ", ";
                        temp.append($3.place);
                        temp += "\n";

                        $$.code = strdup(temp.c_str());
                        $$.place = strdup(dest.c_str());
                     }
                     | term MOD term
                     {
                        std::string temp;
                        std::string dest = new_temp();

                        temp.append($1.code);
                        temp.append($3.code);
                        temp += ". " + dest + "\n";
                        temp += "%% " + dest + ", ";
                        temp.append($1.place);
                        temp += ", ";
                        temp.append($3.place);
                        temp += "\n";

                        $$.code = strdup(temp.c_str());
                        $$.place = strdup(dest.c_str());
                     }
                     ;

term: MINUS var 
        {
               std::string temp;
               std::string dest = new_temp();

               temp.append($2.code);

               std::string var_temp; 
               if ($2.arr) {
                 var_temp = new_temp();
                 temp += ". " + var_temp + "\n";      
                 temp += "=[] " + var_temp + ", ";
                 temp.append($2.place);
                 temp += "\n";      
               }
               else
                 var_temp.append($2.place);       

               temp += ". " + dest + "\n";
               temp += "- " + dest + ", ";
               temp.append("0");
               temp += ", ";
               temp += var_temp;
               temp += "\n";

               $$.code = strdup(temp.c_str());
               $$.place = strdup(dest.c_str());   
        }
      | MINUS NUMBER 
        {
               std::string temp;
               std::string dest = new_temp();

               temp.append(std::to_string($2));
               temp += ". " + dest + "\n";
               temp += "- " + dest + ", ";
               temp.append("0");
               temp += ", ";
               temp.append(std::to_string($2));
               temp += "\n";

               $$.code = strdup(temp.c_str());
               $$.place = strdup(dest.c_str());   
        }
      | MINUS L_PAREN expression R_PAREN 
        {
               std::string temp;
               std::string dest = new_temp();

               temp.append($3.code);
               temp += ". " + dest + "\n";
               temp += "- " + dest + ", ";
               temp.append("0");
               temp += ", ";
               temp.append($3.place);
               temp += "\n";

               $$.code = strdup(temp.c_str());
               $$.place = strdup(dest.c_str());   
        }
      | var
      {
              std::string dest ($1.place);
              std::string code ($1.code);

              if ($1.arr) {
                 std::string temp = new_temp();
                 code += ". " + temp + "\n";
                 code += "=[] " + temp + ", " + dest + "\n";
                 dest = temp;        
              }

              $$.place = strdup(dest.c_str());
              $$.code = strdup(code.c_str());
      }
      | NUMBER 
      {
              std::string temp;
              temp.append(std::to_string($1));
              $$.place = strdup(temp.c_str());
              $$.code = strdup("");
      }
      | L_PAREN expression R_PAREN
      {
              $$.place = strdup($2.place);
              $$.code = strdup($2.code);
      }
      | IDENT L_PAREN optional_exprs R_PAREN {
                // std::string temp;
                // std::string param = new_temp();
                std::string dest = new_temp();
                std::string func_name = strdup($1);

                if (funcs.find(func_name) == funcs.end()) {
                        printf("Function %s is not declared!\n", func_name.c_str());
                }

                int left = 0;
                int right = 0;
                std::string parse($3.place);
                std::string temp;
                bool ex = false;
                temp.append($3.code);
                while (!ex && parse.size() > 0) {
                        right = parse.find("|", left);
                        std::string ident;
                        if (right == std::string::npos) {
                                ident = parse.substr(left, right);
                                ex = true;        
                        }
                        else {
                                ident = parse.substr(left, right - left);
                                left = right + 1;    
                        }
                        temp += "param " + ident + "\n";
                        // temp.append(ident);
                }  

                // temp += ". " + param + "\n";
                // temp += "= " + param + ", ";
                // temp.append($3.place);
                // temp += "\n";
                

                temp += ". " + dest + "\n";
                temp += "call " + func_name + ", " + dest + "\n";

                $$.place = strdup(dest.c_str());
                $$.code = strdup(temp.c_str());
      }
      ;

optional_exprs: {
                        $$.place = strdup("");
                        $$.code = strdup("");
                }
                | chained_exprs
                {                        
                        $$.code = strdup($1.code);
                        $$.place = strdup($1.place);
                }
                ;

chained_exprs: expression 
                {
                        $$.code = strdup($1.code);
                        $$.place = strdup($1.place);
                }           
                | expression COMMA chained_exprs
                {
                        std::string temp;
                        std::string dtemp;

                        dtemp.append($1.place);
                        dtemp.append("|");
                        dtemp.append($3.place);
                        temp.append($1.code);
                        temp.append($3.code);
                        
                        $$.code = strdup(temp.c_str());
                        $$.place = strdup(dtemp.c_str());
                }
                ;

var: IDENT                                                      
        {
                std::string temp;
                $$.code = strdup("");
                std::string ident = strdup($1);
                if (funcs.find(ident) == funcs.end() && varTemp.find(ident) == varTemp.end()) {
                        printf("Identifier %s is not declared.\n", ident.c_str());
                }
                else if (arrSize[ident] > 1) {
                        printf("Did not provide index for array Identifier %s.\n", ident.c_str());
                }

                $$.place = strdup(ident.c_str());
                $$.arr = false; 
        }
        | IDENT L_SQUARE_BRACKET expression R_SQUARE_BRACKET       
        {
              std::string temp;
              std::string ident = strdup($1);
              if (funcs.find(ident) == funcs.end() && varTemp.find(ident) == varTemp.end()) {
                      printf("Identifier %s is not declared.\n", ident.c_str());
              } 
              else if (arrSize[ident] == 1) {
                      printf("Provided index for non-array Identifier %s.\n", ident.c_str());
              }

              temp.append(ident);
              temp.append(", ");
              temp.append($3.place);
              $$.code = strdup($3.code);
              $$.place = strdup(temp.c_str());
              $$.arr = true;
        }
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

std::string new_temp() {
        std::string t = "t" + std::to_string(tempCount);
        tempCount++;
        return t;
}

std::string new_label() {
        std::string l = "L" + std::to_string(labelCount);
        labelCount++;
        return l;
}
