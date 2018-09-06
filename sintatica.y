%{
#include <iostream>
#include <string>
#include <sstream>
#include "helper.cpp"

#define YYSTYPE atributos

using namespace std;

struct atributos
{
	string label;
	string traducao;
	string tipo;
};

int yylex(void);
void yyerror(string);
%}

%token TK_NUM
%token TK_MAIN TK_ID TK_TIPO
%token TK_FIM TK_ERROR

%start S

%left '+' '-'
%left '*' '/'

%%

S 			: TK_TIPO TK_MAIN '(' ')' BLOCO
			{
				cout << "/*R3 Compiler*/\n" << "#include <iostream>\n#include<string.h>\n#include<stdio.h>\nint main(void)\n{\n" << $5.traducao << "\treturn 0;\n}" << endl; 
			}
			;

BLOCO		: '{' COMANDOS '}'
			{
				$$.traducao = $2.traducao;
			}
			;

COMANDOS	: COMANDO COMANDOS
			|
			;

COMANDO 	: E ';'
			;

E 			: E '+' E
			{
				$$.label = nameGen();
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " + " + $3.label + ";\n";
			}
			| E '-' E
			{
				$$.label = nameGen();
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " - " + $3.label + ";\n";
			}
			| E '/' E
			{
				$$.label = nameGen();
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " / " + $3.label + ";\n";
			}
			| E '*' E
			{
				$$.label = nameGen();
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " * " + $3.label + ";\n";
			}
			| '(' E ')'
			{
				$$.label = $2.label;
				$$.traducao =  $2.traducao;
			}
			| TK_NUM
			{
				$$.label = nameGen();
				$$.traducao = "\t" + $$.label + " = " + $1.traducao + ";\n";
			}
			| TK_ID
			{
				int aux = searchMatrix($1.label);
				if(aux != -1){
					$$.traducao = matriz[1][contadorMatriz];
				}
				else{
					yyerror("id not declared");
				}
			}
			| TK_TIPO TK_ID
			{
				matriz[0][contadorMatriz] = $2.label;
				matriz[1][contadorMatriz] = $2.traducao;
				matriz[2][contadorMatriz] = $1.label;
				$$.traducao = $1.label + $2.traducao;
			}
			| TK_ID '=' E
			{

			}
			;

%%

#include "lex.yy.c"

int yyparse();

int main( int argc, char* argv[] )	
{
	yyparse();

	return 0;
}

void yyerror( string MSG )
{
	cout << MSG << endl;
	exit (0);
}
			
