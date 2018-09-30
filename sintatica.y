%{
#include <iostream>
#include <string>
#include <sstream>
#include "helper.cpp"


using namespace std;



int yylex(void);
void yyerror(string);
%}

%token TK_NUM TK_REAL TK_BOOL
%token TK_MAIN TK_ID TK_TIPO
%token TK_FIM TK_ERROR

%start S

%right '='
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
			{
				$$.traducao = $1.traducao + $2.traducao;
			}
			|
			{
				$$.label = "";
				$$.traducao = "";
				$$.tipo = "";
			}
			;

COMANDO 	: E ';'
			;

E 			: E '+' E
			{
				switch(ajeitarExpressao($$, $1, "+", $3)){
					case -1:
						yyerror("no operation of type '+' defined for types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n");
					case -2:
						yyerror("cannot convert types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n");
					case 1:
						break;
				}
			}
			| E '-' E
			{
				switch(ajeitarExpressao($$, $1, "-", $3)){
					case -1:
						yyerror("no operation of type '-' defined for types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n");
					case -2:
						yyerror("cannot convert types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n");
					case 1:
						break;
				}
			}
			| E '/' E
			{
				switch(ajeitarExpressao($$, $1, "/", $3)){
					case -1:
						yyerror("no operation of type '/' defined for types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n");
					case -2:
						yyerror("cannot convert types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n");
					case 1:
						break;
				}
			}
			| E '*' E
			{
				switch(ajeitarExpressao($$, $1, "*", $3)){
					case -1:
						yyerror("no operation of type '*' defined for types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n");
					case -2:
						yyerror("cannot convert types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n");
					case 1:
						break;
				}
			}
			| E '<' E
			{
				switch(ajeitarExpressao($$, $1, "<", $3)){
					case -1:
						yyerror("no operation of type '<' defined for types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n");
					case -2:
						yyerror("cannot convert types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n");
					case 1:
						break;
				}
			}
			| E '>' E
			{
				switch(ajeitarExpressao($$, $1, ">", $3)){
					case -1:
						yyerror("no operation of type '>' defined for types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n");
					case -2:
						yyerror("cannot convert types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n");
					case 1:
						break;
				}
			}
			| '(' E ')'
			{
				$$.label = $2.label;
				$$.traducao =  $2.traducao;
			}
			| TK_NUM
			{
				$$.label = nameGen();
				$$.tipo = "int";
				$$.traducao = "\t" + $$.tipo + " " + $$.label + " = " + $1.traducao + ";\n";
				
			}
			| TK_REAL
			{
				$$.label = nameGen();
				$$.tipo = "float";
				$$.traducao = "\t" + $$.tipo + " " + $$.label + " = " + $1.traducao + ";\n";
			}
			| TK_BOOL
			{
				$$.label = nameGen();
				$$.tipo = "boolean";
				$$.traducao = "\t" + $$.tipo + " " + $$.label + " = " + $1.traducao + ";\n";
			}
			| TK_TIPO TK_ID
			{
				if (isIdDeclared($2.label)){
					yyerror("id already declared\nLine: " + to_string(lineNumber) + "\n");
				}
				$2.traducao = nameGen();
				$2.tipo = $1.label;
				addMatrix($2);
				$$.traducao = "\t" + $1.label + " " + $2.traducao + ";\n";
			}
			| TK_ID '=' E
			{
				string preTraducao = $3.traducao;
				string atribuicao = "";
				if (isIdDeclared($1.label)){
					$1.tipo = getType($1.label);
					if ($1.tipo != $3.tipo){
						if (ehConversivel($1.tipo, $3.tipo)){
							string novoTemp = nameGen();
							preTraducao = preTraducao + "\t" + $3.tipo + " " + novoTemp + ";\n";
							changeTempName($1.label, novoTemp);
						}
						else{
							yyerror("id of type " + $1.tipo + " can not be of type " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n");
						}
					}
					$1.traducao = getTempName($1.label);
					$$.traducao = preTraducao + "\t" + $1.traducao + " = " + $3.label + ";\n";
				}
				else{
					yyerror("id not declared\nLine: " + to_string(lineNumber) + "\n");
				}
			}
			| TK_ID
			{
				int aux = searchMatrix($1.label);				//isIdDeclared não traz o índice, por isso não é usado aqui
				if(aux != -1){
					$$.label = matriz[1][aux];
					$$.tipo = matriz[2][aux];
				}
				else{
					yyerror("id not declared\nLine: " + to_string(lineNumber) + "\n");
				}
			} 
			;

%%

#include "lex.yy.c"

int yyparse();

int main( int argc, char* argv[] )	
{
	criarVetorOp();
	criarVetorConversoes();
	printVetorOp();
	yyparse();

	return 0;
}

void yyerror( string MSG )
{
	cout << MSG << endl;
	exit (0);
}
			
