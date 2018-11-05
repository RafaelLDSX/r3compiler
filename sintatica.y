%{
#include <iostream>
#include <string>
#include <sstream>
#include "helper.cpp"


using namespace std;



int yylex(void);
void yyerror(string);
%}

%token TK_IF
%token TK_SOMA TK_SUBTRACAO TK_DIVISAO TK_MULTIPLICACAO TK_MENOR TK_MAIOR TK_MENORIGUAL TK_MAIORIGUAL TK_ATRIBUICAO TK_IGUAL TK_DIFERENTE TK_COMENTARIO
%token TK_NUM TK_REAL TK_BOOL
%token TK_MAIN TK_ID TK_TIPO
%token TK_FIM TK_ERROR

%start S

%right TK_ATRIBUICAO
%left TK_MENOR TK_MENORIGUAL TK_MAIOR TK_MAIORIGUAL TK_IGUAL TK_DIFERENTE
%left TK_SOMA TK_SUBTRACAO
%left TK_MULTIPLICACAO TK_DIVISAO


%%

S 			: TK_TIPO TK_MAIN '(' ')' BLOCO
			{
				cout << "/*R3 Compiler*/\n" << "#include <iostream>\n#include<string.h>\n#include<stdio.h>\nint main(void)\n{\n" << "\t//declaracoes\n" << declaracoes << "\n" << $5.traducao << "\treturn 0;\n}" << endl; 
			}
			;
EMPILHA		:
			{
				criarTabelaDeSimbolos();
			}
			;
BLOCO		: EMPILHA '{' COMANDOS '}'
			{
				$$.traducao = $3.traducao;
				desempilharTabelaDeSimbolos();
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
			{
				$$.traducao = $1.traducao;
			}
			| STMT ';'
			{
				$$.traducao = $1.traducao;
			}
			| CTRL
			{
				$$.traducao = $1.traducao;
			}
			| BLOCO
			{
				$$.traducao = $1.traducao;
			}
			;

CTRL 		: TK_IF E COMANDO
			{
				string ifBlock = labelNameGen();
				string end = labelNameGen();
				if($2.tipo != "boolean"){
					yyerror("expression is not boolean");
				}
				$$.traducao = $2.traducao + "\tif ( " + $2.tempLabel + " )" 
					+ "\n\t\tgoto " + ifBlock + ";"
					+ "\n\tgoto " + end + ";"
					+ "\n\t" + ifBlock + ":" 
					+ "\n" + $3.traducao
					+ "\t" + end + ":\n";
			}

STMT		: TK_TIPO TK_ID
			{
				if (isIdDeclared($2.label)){
					yyerror("id already declared\nLine: " + to_string(lineNumber) + "\n");
				}
				$2.tempLabel = nameGen();
				$2.tipo = $1.label;
				addMatrix($2);
				$$.traducao = "";
				declaracoes += "\t" + $1.label + " " + $2.tempLabel + ";\n";
			}
			| TK_ID TK_ATRIBUICAO E
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

E 			: E TK_SOMA E
			{
				switch(ajeitarExpressao($$, $1, $2.label, $3)){
					case -1:
						yyerror("no operation of type '+' defined for types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n");
					case -2:
						yyerror("cannot convert types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n");
					case 1:
						break;
				}
			}
			| E TK_SUBTRACAO E
			{
				switch(ajeitarExpressao($$, $1, $2.label, $3)){
					case -1:
						yyerror("no operation of type '-' defined for types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n");
					case -2:
						yyerror("cannot convert types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n");
					case 1:
						break;
				}
			}
			| E TK_DIVISAO E
			{
				switch(ajeitarExpressao($$, $1, $2.label, $3)){
					case -1:
						yyerror("no operation of type '/' defined for types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n");
					case -2:
						yyerror("cannot convert types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n");
					case 1:
						break;
				}
			}
			| E TK_MULTIPLICACAO E
			{
				switch(ajeitarExpressao($$, $1, $2.label, $3)){
					case -1:
						yyerror("no operation of type '*' defined for types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n");
					case -2:
						yyerror("cannot convert types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n");
					case 1:
						break;
				}
			}
			| E TK_MENOR E
			{
				switch(ajeitarExpressao($$, $1, $2.label, $3)){
					case -1:
						yyerror("no operation of type '<' defined for types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n");
					case -2:
						yyerror("cannot convert types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n");
					case 1:
						break;
				}
			}
			| E TK_MAIOR E
			{
				switch(ajeitarExpressao($$, $1, $2.label, $3)){
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
				$$.tempLabel = $2.tempLabel;
				$$.traducao =  $2.traducao;
			}
			| TK_NUM
			{
				$$.label = nameGen();
				$$.tempLabel = $$.label;
				$$.tipo = "int";
				$$.traducao = "";
				declaracoes += "\t" + $$.tipo + " " + $$.label + " = " + $1.traducao + ";\n";
				
			}
			| TK_REAL
			{
				$$.label = nameGen();
				$$.tempLabel = $$.label;
				$$.tipo = "float";
				$$.traducao = "";
				declaracoes += "\t" + $$.tipo + " " + $$.label + " = " + $1.traducao + ";\n";
			}
			| TK_BOOL
			{
				$$.label = nameGen();
				$$.tempLabel = $$.label;
				$$.tipo = "boolean";
				$$.traducao = "";
				declaracoes += "\t" + $$.tipo + " " + $$.label + " = " + $1.traducao + ";\n";
			}
			| '(' TK_TIPO ')' TK_ID
			{
				$$.traducao = "";
				$$.label = nameGen();
				$$.tempLabel = $$.label;
				$$.tipo = $2.label;
				$$.traducao = "";
				declaracoes += "\t" + $$.tipo + " " + $$.label + " = " + $1.traducao + ";\n";
				addMatrix($$);
			}
			// | TK_ID TK_ATRIBUICAO E
			// {
			// 	string preTraducao = $3.traducao;
			// 	string atribuicao = "";
			// 	if (isIdDeclared($1.label)){
			// 		$1.tipo = getType($1.label);
			// 		if ($1.tipo != $3.tipo){
			// 			if (ehConversivel($1.tipo, $3.tipo)){
			// 				string novoTemp = nameGen();
			// 				preTraducao = preTraducao + "\t" + $3.tipo + " " + novoTemp + ";\n";
			// 				changeTempName($1.label, novoTemp);
			// 			}
			// 			else{
			// 				yyerror("id of type " + $1.tipo + " can not be of type " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n");
			// 			}
			// 		}
			// 		$1.traducao = getTempName($1.label);
			// 		$$.traducao = preTraducao + "\t" + $1.traducao + " = " + $3.label + ";\n";
			// 	}
			// 	else{
			// 		yyerror("id not declared\nLine: " + to_string(lineNumber) + "\n");
			// 	}
			// }
			| TK_ID
			{
				atributos aux = procurarNoEscopo($1.label);
				if(aux.label !=  "NULL"){
					// $$.label = matriz[1][aux];
					// $$.tipo = matriz[2][aux];
					$$ = aux;
					$$.traducao = "";
					$$.label = $$.tempLabel;							//gambiarra
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
	criarTabelaDeSimbolos();
	criarVetorOp();
	criarVetorConversoes();
	yyparse();

	return 0;
}

void yyerror( string MSG )
{
	cout << MSG << endl;
	exit (0);
}
			
