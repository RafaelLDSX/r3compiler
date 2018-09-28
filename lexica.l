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

%option noyywrap
%%

"\n"		{ lineNumber++; }

{DELIM} 	{}

"main"		{return TK_MAIN;}

"int"		{ yylval.label = "int"; return TK_TIPO; }

"float"		{ yylval.label = "float"; return TK_TIPO; }

"char"		{ yylval.label = "char"; return TK_TIPO; }

"boolean"	{ yylval.label = "boolean"; return TK_TIPO; }



[(){}[\];,]	{ return *yytext; }

[+\-*/=]	{ return *yytext; }

{NUM}		{ yylval.traducao = yytext; return TK_NUM; }
{REAL}		{ yylval.traducao = yytext; return TK_REAL; }
{ID}		{ yylval.label = yytext; return TK_ID; }

.			{ *yytext; }

%%
