%{
#include <iostream>
#include <string>
#include <sstream>
#include "helper.cpp"



using namespace std;



int yylex(void);
void yyerror(string);
%}

%token TK_NUM TK_REAL
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
				string preTraducao =  $1.traducao + $3.traducao;
				$$.tipo = checarOp("+", $1.tipo, $3.tipo);
				string thisOp = $1.label + " + " + $3.label;
				if ($$.tipo == ""){
					yyerror("no op defined for these types\n");
				}
				$$.label = nameGen();
				if ($1.tipo != $$.tipo){
					string aux = nameGen();
					preTraducao = preTraducao + "\t" + $$.tipo + " " + aux + " = (" + $$.tipo + ") " + $1.label + ";\n";
					thisOp = aux + " + " + $3.label;
				}
				else if ($3.tipo != $$.tipo){
					string aux = nameGen();
					preTraducao = preTraducao + "\t" + $$.tipo + " " + aux + " = (" + $$.tipo + ") " + $3.label + ";\n";
					thisOp = $1.label + " + " + aux;
				}
				$$.traducao = preTraducao + "\t" + $$.tipo + " " + $$.label + ";\n" + "\t" + $$.label + " = " + thisOp + ";\n";
			}
			| E '-' E
			{
				string preTraducao =  $1.traducao + $3.traducao;
				$$.tipo = checarOp("-", $1.tipo, $3.tipo);
				string thisOp = $1.label + " - " + $3.label;
				if ($$.tipo == ""){
					yyerror("no op defined for these types\n");
				}
				$$.label = nameGen();
				if ($1.tipo != $$.tipo){
					string aux = nameGen();
					preTraducao = preTraducao + "\t" + $$.tipo + " " + aux + " = (" + $$.tipo + ") " + $1.label + ";\n";
					thisOp = aux + " - " + $3.label;
				}
				else if ($3.tipo != $$.tipo){
					string aux = nameGen();
					preTraducao = preTraducao + "\t" + $$.tipo + " " + aux + " = (" + $$.tipo + ") " + $3.label + ";\n";
					thisOp = $1.label + " - " + aux;
				}
				$$.traducao = preTraducao + "\t" + $$.tipo + " " + $$.label + ";\n" + "\t" + $$.label + " = " + thisOp + ";\n";
			}
			| E '/' E
			{
				string preTraducao =  $1.traducao + $3.traducao;
				$$.tipo = checarOp("/", $1.tipo, $3.tipo);
				string thisOp = $1.label + " / " + $3.label;
				if ($$.tipo == ""){
					yyerror("no op defined for these types\n");
				}
				$$.label = nameGen();
				if ($1.tipo != $$.tipo){
					string aux = nameGen();
					preTraducao = preTraducao + "\t" + $$.tipo + " " + aux + " = (" + $$.tipo + ") " + $1.label + ";\n";
					thisOp = aux + " / " + $3.label;
				}
				else if ($3.tipo != $$.tipo){
					string aux = nameGen();
					preTraducao = preTraducao + "\t" + $$.tipo + " " + aux + " = (" + $$.tipo + ") " + $3.label + ";\n";
					thisOp = $1.label + " / " + aux;
				}
				$$.traducao = preTraducao + "\t" + $$.tipo + " " + $$.label + ";\n" + "\t" + $$.label + " = " + thisOp + ";\n";
			}
			| E '*' E
			{
				string preTraducao =  $1.traducao + $3.traducao;
				$$.tipo = checarOp("*", $1.tipo, $3.tipo);
				string thisOp = $1.label + " * " + $3.label;
				if ($$.tipo == ""){
					yyerror("no op defined for these types\n");
				}
				$$.label = nameGen();
				if ($1.tipo != $$.tipo){
					string aux = nameGen();
					preTraducao = preTraducao + "\t" + $$.tipo + " " + aux + " = (" + $$.tipo + ") " + $1.label + ";\n";
					thisOp = aux + " * " + $3.label;
				}
				else if ($3.tipo != $$.tipo){
					string aux = nameGen();
					preTraducao = preTraducao + "\t" + $$.tipo + " " + aux + " = (" + $$.tipo + ") " + $3.label + ";\n";
					thisOp = $1.label + " * " + aux;
				}
				$$.traducao = preTraducao + "\t" + $$.tipo + " " + $$.label + ";\n" + "\t" + $$.label + " = " + thisOp + ";\n";
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
			| TK_TIPO TK_ID
			{
				if (isIdDeclared($2.label)){
					yyerror("id already declared\n");
				}
				$2.traducao = nameGen();
				$2.tipo = $1.label;
				addMatrix($2);
				$$.traducao = "\t" + $1.label + " " + $2.traducao + ";\n";
			}
			| TK_ID '=' E
			{
				if (isIdDeclared($1.label)){
					
					$1.traducao = getTempName($1.label);
					$$.traducao = $3.traducao +"\t" + $1.traducao + " = " + $3.label + ";\n";
				}
				else{
					yyerror("id not declared\n");
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
					yyerror("id not declared\n");
				}
			} 
			;

%%

#include "lex.yy.c"

int yyparse();

int main( int argc, char* argv[] )	
{
	criarVetorOp();
	printVetorOp();
	yyparse();

	return 0;
}

void yyerror( string MSG )
{
	cout << MSG << endl;
	exit (0);
}
			
