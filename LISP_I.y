%{
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <iostream>
#include <string.h>
#include <sstream>
#include <stack>
#include <queue>
#include "SymbolTable.h"

int numLines = 1; 

void printRule(const char *, const char *);
int yyerror(const char *s);
void printTokenInfo(const char* tokenType, const char* lexeme);
void beginScope();
void endScope();
void addTable(char* symbol_value);
bool findEntryInAnyScope(const string theName);
stack<SYMBOL_TABLE> scopeStack;
int findEntry(const string theName);
int findSValue(const string theName);
string InputValue;
int ArugmentCounter;
bool functionCalled;
string GlobalSvalue;
ostringstream convertS;
queue<int> ParamQueue;
int Arithfrist;
int Arithlast;
int Arithresult;
stack<string> EXPRstack;

extern "C" 
{
    int yyparse(void);
    int yylex(void);
    int yywrap() { return 1; }
}

%}

%union 
{
  char* text;
  TYPE_INFO typeInfo;
};

/* Token declarations */
%token  T_LETSTAR T_LAMBDA T_INPUT T_PRINT T_IF T_LPAREN T_RPAREN T_ADD T_MULT T_DIV T_SUB T_AND T_OR T_LT T_GT T_LE T_GE T_EQ T_NE T_NOT T_IDENT T_INTCONST T_STRCONST T_T T_NIL T_UNKNOWN 

%type <text> T_IDENT T_INTCONST T_STRCONST T_GE T_LT T_LE T_GT T_EQ T_NE T_AND T_OR T_MULT T_ADD T_SUB T_DIV
%type <typeInfo> N_CONST N_EXPR N_PARENTHESIZED_EXPR N_IF_EXPR N_ARITHLOGIC_EXPR N_LET_EXPR N_LAMBDA_EXPR N_PRINT_EXPR N_INPUT_EXPR N_EXPR_LIST N_UN_OP N_BIN_OP N_ID_LIST N_ARITH_OP N_LOG_OP N_REL_OP

/* Starting point */
%start		N_START

/* Translation rules */
%%
N_START		: N_EXPR
			{
			printRule("START", "EXPR");
			printf("\n---- Completed parsing ----\n\n");
			printf("\nValue of the expression is: %s\n", $1.value);
			return 0;
			}
			;
N_EXPR		: N_CONST
			{
			printRule("EXPR", "CONST");
			$$.type = $1.type;
			$$.numParams = $1.numParams;
			$$.returnType = $1.returnType;
			$$.value = $1.value;
			
			EXPRstack.push(string($$.value));
			}
            | T_IDENT
            {
			printRule("EXPR", "IDENT");
			
			
			 bool found = findEntryInAnyScope(string($1));
			 if (found == false)
			 {
			   yyerror("Undefined identifier");
			   return(1);
			 }
			
			$$.type = findEntry(string($1));
			$$.numParams = NOT_APPLICABLE;
			$$.returnType = NOT_APPLICABLE;
			findSValue(string($1));
			$$.value = GlobalSvalue.c_str();
			
			EXPRstack.push(string($$.value));
			}
            | T_LPAREN N_PARENTHESIZED_EXPR T_RPAREN
            {
			printRule("EXPR", "( PARENTHESIZED_EXPR )");
			$$.type = $2.type;
			$$.numParams = $2.numParams;
			$$.returnType = $2.returnType;
			$$.value = $2.value;
			
			EXPRstack.push(string($$.value));
			}
			;
N_CONST		: T_INTCONST
			{
			printRule("CONST", "INTCONST");
			$$.type = INT;
			$$.numParams = NOT_APPLICABLE;
			$$.returnType = NOT_APPLICABLE;
			$$.value = $1;
			}
			| T_STRCONST
			{
			printRule("CONST", "STRCONST");
			$$.type = STR;
			$$.numParams = NOT_APPLICABLE;
			$$.returnType = NOT_APPLICABLE;
			$$.value = $1;
			}
			| T_T
			{
			printRule("CONST", "t");
			$$.type = BOOL;
			$$.numParams = NOT_APPLICABLE;
			$$.returnType = NOT_APPLICABLE;
			$$.value = "t";
			}
			| T_NIL
			{
			printRule("CONST", "nil");
			$$.type = BOOL;
			$$.numParams = NOT_APPLICABLE;
			$$.returnType = NOT_APPLICABLE;
			$$.value = "nil";
			}
			;
N_PARENTHESIZED_EXPR	: N_ARITHLOGIC_EXPR
						{
						printRule("PARENTHESIZED_EXPR", "ARITHLOGIC_EXPR");
						$$.type = $1.type;
						$$.numParams = $1.numParams;
						$$.returnType = $1.returnType;
						$$.value = $1.value;
						
						}
						| N_IF_EXPR
						{
						printRule("PARENTHESIZED_EXPR", "IF_EXPR");
						$$.type = $1.type;
						$$.numParams = $1.numParams;
						$$.returnType = $1.returnType;
						$$.value = $1.value;
						
						}
						| N_LET_EXPR
						{
						printRule("PARENTHESIZED_EXPR", "LET_EXPR");
						$$.type = $1.type;
						$$.numParams = $1.numParams;
						$$.returnType = $1.returnType;
						$$.value = $1.value;
						
						}
						| N_LAMBDA_EXPR
						{
						printRule("PARENTHESIZED_EXPR", "LAMBDA_EXPR");
						$$.type = $1.type;
						$$.numParams = $1.numParams;
						$$.returnType = $1.returnType;
						
						}
						| N_PRINT_EXPR
						{
						printRule("PARENTHESIZED_EXPR", "PRINT_EXPR");
						$$.type = $1.type;
						$$.numParams = $1.numParams;
						$$.returnType = $1.returnType;
						$$.value = $1.value;
						
						}
						| N_INPUT_EXPR
						{
						printRule("PARENTHESIZED_EXPR", "INPUT_EXPR");
						$$.type = $1.type;
						$$.numParams = $1.numParams;
						$$.returnType = $1.returnType;
						$$.value = $1.value;
						
						}
						| N_EXPR_LIST
						{
						if(functionCalled == true)
						{
							if(ArugmentCounter > ParamQueue.front())
							{
							yyerror("Too many parameters in function call");
							return(1);
							}
							else if(ArugmentCounter < ParamQueue.front())
							{
							yyerror("Too few parameters in function call");
							return(1);
							}
							functionCalled = false;
						}
						printRule("PARENTHESIZED_EXPR", "EXPR_LIST");
						$$.type = $1.type;
						$$.numParams = $1.numParams;
						$$.returnType = $1.returnType;
						$$.value = $1.value;
						ParamQueue.pop();
						
						}
						;
N_ARITHLOGIC_EXPR	: N_UN_OP N_EXPR
					{
					bool value0;
					printRule("ARITHLOGIC_EXPR", "UN_OP EXPR");
					if($2.type == FUNCTION) 
					{
					yyerror("Arg 1 cannot be function");
					return(1);
					}
					if(strcmp($2.value,"nil") != 0)
					 {
					   value0 = false;
					 }
					 else{value0 = true;}
					
					if(value0 == false){$$.value = "nil";}
					else{$$.value = "t";}
					$$.type = BOOL; 
					$$.numParams = NOT_APPLICABLE;
					$$.returnType = NOT_APPLICABLE;
					}
					| N_BIN_OP N_EXPR N_EXPR
					{
					printRule("ARITHLOGIC_EXPR", "BIN_OP EXPR EXPR");
					bool value1, value2;

					if($1.type == INT)
					{
					  if($2.type != INT && $2.type != 3 && $2.type != 5 && $2.type != 7){ yyerror("Arg 1 must be integer"); return(1);}
					  if($3.type != INT && $3.type != 3 && $3.type != 5 && $3.type != 7){ yyerror("Arg 2 must be integer"); return(1);}
					  convertS.str("");
					  Arithlast = atoi(EXPRstack.top().c_str());
					  EXPRstack.pop();
					  Arithfrist = atoi(EXPRstack.top().c_str());
					  EXPRstack.pop();
					 
					  if(strcmp($1.value,"+") == 0)
					  {
					    Arithresult = Arithfrist + Arithlast;
					    convertS << Arithresult;
						GlobalSvalue = convertS.str();
						$$.value = GlobalSvalue.c_str();
					  }
					  else if(strcmp($1.value,"-") == 0)
					  {
					    Arithresult = Arithfrist - Arithlast;
					    convertS << Arithresult;
						GlobalSvalue = convertS.str();
						$$.value = GlobalSvalue.c_str();
					  }
					  else if(strcmp($1.value,"*") == 0)
					  {
					    Arithresult = Arithfrist * Arithlast;
					    convertS << Arithresult;
						GlobalSvalue = convertS.str();
						$$.value = GlobalSvalue.c_str();
					  }
					  else if(strcmp($1.value,"/") == 0)
					  {
					    if(Arithlast == 0)
						{
						  yyerror("Attempted division by zero");
						  return(1);
						}
					    Arithresult = Arithfrist / Arithlast;
					    convertS << Arithresult;
						GlobalSvalue = convertS.str();
						$$.value = GlobalSvalue.c_str();
					  }
					  $$.type = INT; 
					  $$.numParams = NOT_APPLICABLE;
					  $$.returnType = NOT_APPLICABLE;
					}
					else if($1.type == INT_OR_STR_OR_BOOL)
					{
					 if($2.type == FUNCTION){ yyerror("Arg 1 cannot be function"); return(1);}
					 if($3.type == FUNCTION){ yyerror("Arg 2 cannot be function"); return(1);}
					 
					 if(strcmp($2.value,"nil") != 0)
					 {
					   value1 = true;
					 }
					 else{value1 = false;}
					 if(strcmp($3.value,"nil") != 0)
					 {
					   value2 = true;
					 }
					 else{value2 = false;}
					 
					 if(strcmp($1.value,"and") == 0)
					 {
					   value1 = value1 && value2;
					 }
					 else if(strcmp($1.value,"or") == 0)
					 {
					   value1 = value1 || value2;
					 }
					 
					 if(value1 == false){$$.value = "nil";}
					 else{$$.value = "t";}
					 $$.type = BOOL; 
					 $$.numParams = NOT_APPLICABLE;
					 $$.returnType = NOT_APPLICABLE;
					}
					else if($1.type == INT_OR_STR)
					{
					 if($2.type == FUNCTION || $2.type == BOOL){ yyerror("Arg 1 must be integer or string"); return(1);}
					 if($3.type == FUNCTION || $3.type == BOOL){ yyerror("Arg 2 must be integer or string"); return(1);}
					 if($2.type == INT)
					 {
					  if($3.type != INT){ yyerror("Arg 2 cannot be function"); return(1);}
					 }
					 else if($2.type == STR)
					 {
					  if($3.type != STR){ yyerror("Arg 2 cannot be function"); return(1);}
				    }
					 
					 
					 if(strcmp($2.value,"nil") != 0)
					 {
					   value1 = true;
					 }
					 else{value1 = false;}
					 if(strcmp($3.value,"nil") != 0)
					 {
					   value2 = true;
					 }
					 else{value2 = false;}
					 
					 if(strcmp($1.value,"<") == 0)
					 {
					   value1 = value1 < value2;
					   if($2.type == INT && $3.type == INT)
					   {
					    value1 = atoi($2.value) < atoi($3.value); 
					   }
					 }
					 else if(strcmp($1.value,">") == 0)
					 {
					   value1 = value1 > value2;
					   if($2.type == INT && $3.type == INT)
					   {
					    value1 = atoi($2.value) > atoi($3.value); 
					   }
					 }
					 else if(strcmp($1.value,"<=") == 0)
					 {
					   value1 = value1 <= value2;
					   if($2.type == INT && $3.type == INT)
					   {
					    value1 = atoi($2.value) <= atoi($3.value);
					   }
					 }
					 else if(strcmp($1.value,">=") == 0)
					 {
					   value1 = value1 >= value2;
					   if($2.type == INT && $3.type == INT)
					   {
					    value1 = atoi($2.value) >= atoi($3.value);
					   }
					 }
					 else if(strcmp($1.value,"=") == 0)
					 {
					   value1 = value1 == value2;
					   if($2.type == INT && $3.type == INT)
					   {
					    value1 = atoi($2.value) == atoi($3.value); 
					   }
					   else if($2.type == STR && $3.type == STR)
					   {
					     value1 = (strcmp($2.value,$3.value) == 0);
					   }
					 }
					 else if(strcmp($1.value,"/=") == 0)
					 {
					   value1 = value1 != value2;
					   if($2.type == INT && $3.type == INT)
					   {
					    value1 = atoi($2.value) != atoi($3.value); 
					   }
					   else if($2.type == STR && $3.type == STR)
					   {
					     value1 = (strcmp($2.value,$3.value) != 0);
					   }
					 }
					 
					 if(value1 == false){$$.value = "nil";}
					 else{$$.value = "t";}
					 $$.type = BOOL; 
					 $$.numParams = NOT_APPLICABLE;
					 $$.returnType = NOT_APPLICABLE;
					}
					}
					;
N_IF_EXPR	: T_IF N_EXPR N_EXPR N_EXPR
			{
			printRule("IF_EXPR", "IF EXPR EXPR EXPR");
			if($2.type == FUNCTION){ yyerror("Arg 1 cannot be function"); return(1);}
			if($3.type == FUNCTION){ yyerror("Arg 2 cannot be function"); return(1);}
			if($4.type == FUNCTION){ yyerror("Arg 3 cannot be function"); return(1);}
			
			$$.type = $2.type;
			$$.numParams = NOT_APPLICABLE;
			$$.returnType = NOT_APPLICABLE;
			
			$$.type = $$.type|$3.type;
			$$.type = $$.type|$4.type;
			
			if(strcmp($2.value,"nil") == 0)
			{
			  $$.value = $4.value;
			}
			else{$$.value = $3.value;}
			
			}
			;
N_LET_EXPR	: T_LETSTAR T_LPAREN N_ID_EXPR_LIST T_RPAREN N_EXPR
			{
			printRule("LET_EXPR", "let* ( ID_EXPR_LIST ) EXPR");
			endScope();
			
			if($5.type == FUNCTION)
			{
			 yyerror("Arg 2 cannot be function"); 
			 return(1);
			}
			
			$$.type = $5.type;
			$$.numParams = NOT_APPLICABLE;
			$$.returnType = NOT_APPLICABLE;
			$$.value = $5.value;
			}
			;
N_ID_EXPR_LIST	: /* empty */
				{
				printRule("ID_EXPR_LIST", "epsilon");
				}
				| N_ID_EXPR_LIST T_LPAREN T_IDENT N_EXPR T_RPAREN
				{
				printRule("ID_EXPR_LIST", "ID_EXPR_LIST ( IDENT EXPR )");
				
				addTable($3);
				bool found = scopeStack.top( ).findEntry(string($3));
				if( found == true)
				{
				  yyerror("Multiply defined identifier");
				  return(1);
				}
				else
				{
				  SYMBOL_TABLE_ENTRY temp = SYMBOL_TABLE_ENTRY(string($3),$4.type,string($4.value));
				  scopeStack.top().addEntry(temp);
				}
				}
				;
N_LAMBDA_EXPR 	: T_LAMBDA T_LPAREN N_ID_LIST T_RPAREN N_EXPR
				{
				printRule("LAMBDA_EXPR", "lambda ( ID_LIST ) EXPR");
				endScope();
				
				if($5.type == FUNCTION)
				{
				 yyerror("Arg 2 cannot be function"); 
				 return(1);
				}
				
				$$.type = FUNCTION;
			    $$.numParams = $3.numParams;
				$$.returnType = $5.type;
				ParamQueue.push($3.numParams);
				}
				;
N_ID_LIST	: /* empty */ 
			{
			printRule("ID_LIST", "epsilon");
			$$.numParams = 0;
			}
			| N_ID_LIST T_IDENT
			{
			printRule("ID_LIST", "ID_LIST IDENT");
			
				addTable($2);
				bool found = scopeStack.top( ).findEntry(string($2));
				if( found == true)
				{
				  yyerror("Multiply defined identifier");
				  return(1);
				}
				else
				{
				  SYMBOL_TABLE_ENTRY temp = SYMBOL_TABLE_ENTRY(string($2),INT, "");
				  scopeStack.top().addEntry(temp);
				}
				$$.numParams++;
			}
			;
N_PRINT_EXPR	: T_PRINT N_EXPR
				{
				printRule("PRINT_EXPR", "print EXPR");
				
				if($2.type == FUNCTION)
				{
				 yyerror("Arg 1 cannot be function"); 
				 return(1);
				}
				
				printf("%s\n",$2.value);
				
				$$.type = $2.type;
			    $$.numParams = NOT_APPLICABLE;
			    $$.returnType = NOT_APPLICABLE;
				$$.value = $2.value;
				}
				;
N_INPUT_EXPR	: T_INPUT
				{
				printRule("INPUT_EXPR", "input");
				
				getline(cin,InputValue);
				if(InputValue.at(0) == '+' || InputValue.at(0) == '-'|| isdigit(InputValue.at(0)))
				{
				  $$.type = INT;
				}
				else
				{
				  $$.type = STR;
				}
			    $$.numParams = NOT_APPLICABLE;
			    $$.returnType = NOT_APPLICABLE;
				$$.value = InputValue.c_str();
				}
				;
N_EXPR_LIST		: N_EXPR N_EXPR_LIST
				{
				printRule("EXPR_LIST", "EXPR EXPR_LIST");
				if($1.type == FUNCTION)
				{
				  $$.type = $1.returnType;
				  functionCalled = true;
				}
				else
				{
				  $$.type = $2.type;
				}
				ArugmentCounter++;
				if($$.type == FUNCTION)
				{
				 yyerror("Arg 1 cannot be function"); 
				 return(1);
				}
				$$.value = $2.value;
				}
				| N_EXPR
				{
				printRule("EXPR_LIST", "EXPR");
				if($1.type == FUNCTION)
				{
				  $$.type = $1.returnType;
				}
				ArugmentCounter = 0;
				if($$.type == FUNCTION)
				{
				 yyerror("Arg 1 cannot be function"); 
				 return(1);
				}
				$$.value = $1.value;
				}
				;
N_BIN_OP	: N_ARITH_OP
			{
			printRule("BIN_OP", "ARITH_OP");
			$$.type = INT;
			$$.numParams = NOT_APPLICABLE;
			$$.returnType = NOT_APPLICABLE;
			$$.value = $1.value;
			}
			| N_LOG_OP 
			{
			printRule("BIN_OP", "LOG_OP");
			$$.type = INT_OR_STR_OR_BOOL;
			$$.numParams = NOT_APPLICABLE;
			$$.returnType = NOT_APPLICABLE;
			$$.value = $1.value;
			}
			| N_REL_OP
			{
			printRule("BIN_OP", "REL_OP");
			$$.type = INT_OR_STR;
			$$.numParams = NOT_APPLICABLE;
			$$.returnType = NOT_APPLICABLE;
			$$.value = $1.value;
			}
			;
N_ARITH_OP	: T_MULT
			{
			printRule("ARITH_OP", "*");
			$$.value = $1;
			}
			| T_SUB
			{
			printRule("ARITH_OP", "-");
			$$.value = $1;
			}
			| T_DIV
			{
			printRule("ARITH_OP", "/");
			$$.value = $1;
			}
			| T_ADD
			{
			printRule("ARITH_OP", "+");
			$$.value = $1;
			}
			;
N_LOG_OP	: T_AND
			{
			printRule("LOG_OP", "and");
			$$.value = $1;
			}
			| T_OR
			{
			printRule("LOG_OP", "or");
			$$.value = $1;
			}
			;
N_REL_OP	: T_LT
			{
			printRule("REL_OP", "<");
			$$.value = $1;
			}
			| T_GT
			{
			printRule("REL_OP", ">");
			$$.value = $1;
			}
			| T_LE
			{
			printRule("REL_OP", "<=");
			$$.value = $1;
			}
			| T_GE
			{
			printRule("REL_OP", ">=");
			$$.value = $1;
			}
			| T_EQ
			{
			printRule("REL_OP", "=");
			$$.value = $1;
			}
			| T_NE
			{
			printRule("REL_OP", "/=");
			$$.value = $1;
			}
			;
N_UN_OP 	: T_NOT
			{
			printRule("UN_OP", "not");
			}
			;
%%

#include "lex.yy.c"
extern FILE *yyin;

void printRule(const char *lhs, const char *rhs) 
{
  printf("%s -> %s\n", lhs, rhs);
  return;
}

int yyerror(const char *s) 
{
  printf("Line %d: %s\n ", numLines, s);
  return(1);
}

void printTokenInfo(const char* tokenType, const char* lexeme) 
{
  printf("TOKEN: %s  LEXEME: %s\n", tokenType, lexeme);
}

void beginScope()
{
  scopeStack.push(SYMBOL_TABLE());
  printf("\n___Entering new scope...\n\n");
}

void endScope()
{
  scopeStack.pop();
  printf("\n___Exiting scope...\n\n");
} 

void addTable(char* symbol_value)
{
  printf("___Adding %s to symbol table\n", symbol_value);
}

//returns true if entry is found in symbol table, false otherwise
bool findEntryInAnyScope(const string theName)
{
  if (scopeStack.empty( )) return(false);
  bool found = scopeStack.top( ).findEntry(theName);
  if (found)
  {
    return(true);
  }
  else 
  { // check in "next higher" scope
    SYMBOL_TABLE symbolTable = scopeStack.top();
	scopeStack.pop();
	found = findEntryInAnyScope(theName);
	scopeStack.push(symbolTable); // restore the stack
	return(found);
  }
}

// finds and returns type value of an entry stored in symbol table
int findEntry(const string theName)
{
  if (scopeStack.empty( )) return(-1);
  bool found = scopeStack.top( ).findEntry(theName);
  if (found)
  {
    SYMBOL_TABLE_ENTRY test = scopeStack.top( ).ReturnEntry(theName);
	int value = test.getTypeCode();
    return(value);
  }
  else 
  { // check in "next higher" scope
    SYMBOL_TABLE symbolTable = scopeStack.top();
	scopeStack.pop();
	found = findEntry(theName);
	scopeStack.push(symbolTable); // restore the stack
	return(found);
  }
}
// finds and returns actual value of an entry stored in symbol table
int findSValue(const string theName)
{
  if (scopeStack.empty( )) return(-1);
  bool found = scopeStack.top( ).findEntry(theName);
  if (found)
  {
    SYMBOL_TABLE_ENTRY test = scopeStack.top( ).ReturnEntry(theName);
	GlobalSvalue = test.getSvalue();
    return(0);
  }
  else 
  { // check in "next higher" scope
    SYMBOL_TABLE symbolTable = scopeStack.top();
	scopeStack.pop();
	found = findSValue(theName);
	scopeStack.push(symbolTable); // restore the stack
	return(found);
  }
}

int main(int argc, char** argv) 
{
  if (argc < 2) 
  {
    printf("You must specify a file in the command line!\n");
	exit(1);
  }
  yyin = fopen(argv[1], "r");
  do 
  {
    yyparse();
  }while(!feof(yyin));
  return 0;
}
