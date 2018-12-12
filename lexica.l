%{
#include <string>
#include "helper.cpp"
%}

ESPACO [ \t]
DIGITO [0-9]
LETRA [A-Za-z_]

DELIM {ESPACO}+
NUM {DIGITO}+
REAL {NUM}+("."{NUM}+)?
CHAR \'({LETRA}|{NUM})\'
ID {LETRA}({LETRA}|{NUM})*
STRING \"({LETRA}|{NUM}|{ESPACO})+\"

%option noyywrap
%%

"\n"		{ lineNumber++; }

{DELIM} 	{}

"main"		{return TK_MAIN;}

"int"		{ yylval.label = "int"; return TK_TIPO; }

"float"		{ yylval.label = "float"; return TK_TIPO; }

"char"		{ yylval.label = "char"; return TK_TIPO; }

"boolean"	{ yylval.label = "boolean"; return TK_TIPO; }

"string"	{ yylval.label = "string"; return TK_TIPO; }

"var"		{ yylval.label = "var";	return TK_TIPO; }

"if"		{ return TK_IF; }

"while"		{ return TK_WHILE; }

"for"		{ return TK_FOR; }

"break"		{ return TK_BREAK; }

"powerBreak" { return TK_POWERBREAK; }

"continue" 	{ return TK_CONTINUE; }

"powerContinue" { return TK_POWERCONTINUE; }

"strict" 	{ return TK_STRICT; }


[(){}[\];,]	{ return *yytext; }

"+"			{yylval.label = yytext; return TK_SOMA; }
"-"			{yylval.label = yytext; return TK_SUBTRACAO; }
"/"			{yylval.label = yytext; return TK_DIVISAO; }
"*"			{yylval.label = yytext; return TK_MULTIPLICACAO; }
"="			{yylval.label = yytext; return TK_ATRIBUICAO; }
"<"			{yylval.label = yytext; return TK_MENOR; }
">"			{yylval.label = yytext; return TK_MAIOR; }
"<="		{yylval.label = yytext; return TK_MENORIGUAL; }
">="		{yylval.label = yytext; return TK_MAIORIGUAL; }
"=="		{yylval.label = yytext; return TK_IGUAL; }
"!="		{yylval.label = yytext; return TK_DIFERENTE; }
"@@"		{yylval.label = yytext; return TK_COMENTARIO; }

{NUM}		{ yylval.traducao = yytext; return TK_NUM; }
{REAL}		{ yylval.traducao = yytext; return TK_REAL; }
{CHAR}		{ yylval.traducao = yytext; return TK_CHAR; }
"true"		{ yylval.traducao = "1"; return TK_BOOL; }
"false"		{ yylval.traducao = "0"; return TK_BOOL; }
{ID}		{ yylval.label = yytext; return TK_ID; }
{STRING}	{ yylval.traducao = yytext; yylval.tamanhoDaString = contarString(yylval.traducao); return TK_STRING; }



.			{ *yytext; }

%%
