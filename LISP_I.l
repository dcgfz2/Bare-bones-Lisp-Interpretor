%{
%}

WSPACE          [ \t\v\r]+
NEWLINE          \n

DIGIT              [0-9]
LETTER           [a-zA-Z]
IDENTIFER       {LETTER}|{DIGIT}|"_"
COMMENT         ;.*{NEWLINE}

IDENT           _{IDENTIFER}*|{LETTER}{IDENTIFER}*
INTCONST       {DIGIT}+|\+{DIGIT}+|\-{DIGIT}+
DOUBLE_QUOTE      \"
STRCONST         {DOUBLE_QUOTE}[^\"\n]*{DOUBLE_QUOTE} 

%%

"let*"                  {
                                printTokenInfo("LETSTAR", yytext);
								beginScope();
                                return T_LETSTAR;
                        }
"if"                    {
                                printTokenInfo("IF", yytext);
                                return T_IF;
                        }
"lambda"                {
                                printTokenInfo("LAMBDA", yytext);
								beginScope();
                                return T_LAMBDA;
                        }
"print"                 {
                                printTokenInfo("PRINT", yytext);
                                return T_PRINT;
                        }
"input"                 {
                                printTokenInfo("INPUT", yytext);
                                return T_INPUT;
                        }
"and"                   {
                                printTokenInfo("AND", yytext);
								yylval.text = strdup(yytext);
                                return T_AND;
                        }
"or"                    {
                                printTokenInfo("OR", yytext);
								yylval.text = strdup(yytext);
                                return T_OR;
                        }
"not"                   {
                                printTokenInfo("NOT", yytext);
                                return T_NOT;
                        }
"t"                     {
                                printTokenInfo("T", yytext);
                                return T_T;
                        }
"nil"                   {
                                printTokenInfo("NIL", yytext);
                                return T_NIL;
                        }
"+"                             {
                                printTokenInfo("ADD", yytext);
								yylval.text = strdup(yytext);
                                return T_ADD;
                        }
"-"                             {
                                printTokenInfo("SUB", yytext);
								yylval.text = strdup(yytext);
                                return T_SUB;
                        }
"*"                             {
                                printTokenInfo("MULT", yytext);
								yylval.text = strdup(yytext);
                                return T_MULT;
                        }
"/"                             {
                                printTokenInfo("DIV", yytext);
								yylval.text = strdup(yytext);
                                return T_DIV;
                        }
"<"                             {
                                printTokenInfo("LT", yytext);
								yylval.text = strdup(yytext);
                                return T_LT;
                        }
">"                             {
                                printTokenInfo("GT", yytext);
								yylval.text = strdup(yytext);
                                return T_GT;
                        }
"<="                    {
                                printTokenInfo("LE", yytext);
								yylval.text = strdup(yytext);
                                return T_LE;
                        }
">="                    {
                                printTokenInfo("GE", yytext);
								yylval.text = strdup(yytext);
                                return T_GE;
                        }
"="                             {
                                printTokenInfo("EQ", yytext);
								yylval.text = strdup(yytext);
                                return T_EQ;
                        }
"/="                    {
                                printTokenInfo("NE", yytext);
								yylval.text = strdup(yytext);
                                return T_NE;
                        }
"("                             {
                                printTokenInfo("LPAREN", yytext);
                                return T_LPAREN;
                        }
")"                             {
                                printTokenInfo("RPAREN", yytext);
                                return T_RPAREN;
                        }
{INTCONST}              {
                                printTokenInfo("INTCONST", yytext);
								yylval.text = strdup(yytext);
                                return T_INTCONST;
                        }
{IDENT}                 {
                                printTokenInfo("IDENT", yytext);
								yylval.text = strdup(yytext);
                                return T_IDENT;
                        }
{STRCONST}              {
                                printTokenInfo("STRCONST", yytext);
								yylval.text = strdup(yytext);
                                return T_STRCONST;
                        }
{NEWLINE}               {
                        numLines++;
                        }
{WSPACE}                { }
.                       {
                                printTokenInfo("UNKNOWN", yytext);
                                return T_UNKNOWN;
                        }
{COMMENT}               {

                        }

%%


