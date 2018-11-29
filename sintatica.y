%{
#include <iostream>
#include <string>
#include <sstream>
#include "helper.cpp"


using namespace std;



int yylex(void);
void yyerror(string);
%}

%token TK_IF TK_WHILE TK_FOR TK_BREAK TK_POWERBREAK TK_CONTINUE TK_POWERCONTINUE
%token TK_SOMA TK_SUBTRACAO TK_DIVISAO TK_MULTIPLICACAO TK_MENOR TK_MAIOR TK_MENORIGUAL TK_MAIORIGUAL TK_ATRIBUICAO TK_IGUAL TK_DIFERENTE TK_COMENTARIO
%token TK_NUM TK_REAL TK_BOOL TK_CHAR TK_STRING
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
				if(errorFlag != 1)
					cout << "/*R3 Compiler*/\n" << "#include <iostream>\n#include<string.h>\n#include<stdio.h>\nint main(void)\n{\n" << "\t//declaracoes\n" << declaracoes << "\n" << $5.traducao << "\treturn 0;\n}" << endl;
				else
					cout << "Erros encontrados: " + to_string(errorCounter) + "\n" + errorString;
			}
			| COMANDO S
			{
				$$.traducao = $1.traducao + $2.traducao;
			}
			;
EMPILHA		:
			{
				criarTabelaDeSimbolos();
			}
			;
EMPILHALABELS :
			{
				$$.label = labelNameGen();
				$$.tempLabel = labelNameGen();
				empilharLabelStruct($$.label, $$.tempLabel);
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

COMANDO		: E ';'
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
					errorFlag = 1;
					errorString += "expression is not boolean";
					//yyerror("expression is not boolean");
				}
				$$.traducao = $2.traducao + "\tif ( " + $2.tempLabel + " )" 
							+ "\n\t\tgoto " + ifBlock + ";"
							+ "\n\tgoto " + end + ";"
							+ "\n\t" + ifBlock + ":" 
							+ "\n" + $3.traducao
							+ "\t" + end + ":\n";
			}
			| EMPILHALABELS TK_WHILE E COMANDO
			{
				string comeco = $1.label;
				string fim = $1.tempLabel;
				$$.traducao = "\t" + comeco + ":\n"
							+ $3.traducao + "\tif ( ! (" + $3.tempLabel + ") )"
							+ "\n\t\tgoto " + fim + ";\n"
							+ $4.traducao
							+ "\tgoto " + comeco + ";"
							+ "\n\t" + fim + ":\n";
				desempilharLabelStruct();
			}
			| EMPILHALABELS TK_FOR '('STMT';'E';'E')' COMANDO
			{
				string comeco = $1.label;
				string fim = $1.tempLabel;
				cout << pilhaDeLabels.back().fim + "\n";
				$$.traducao = $4.traducao 
							+ "\t" + comeco + ";\n"
							+ $6.traducao
							+ "\tif ( ! (" + $6.tempLabel + ") )"
							+ "\n\t\tgoto " + fim + ";\n"
						 	+ $10.traducao
							+ $8.traducao
							+ "\tgoto " + comeco + ";" 
							+ "\n\t" + fim + ":\n";
				desempilharLabelStruct();
				cout << "DESEMPILHADO\n";

			}
			| TK_BREAK ';'
			{
				if(pilhaDeLabels.size() < 1){
					errorFlag = 1;
					errorString += "no loop to break out of\nLine: " + to_string(lineNumber) + "\n";
					//yyerror("no loop to break out of\nLine: " + to_string(lineNumber) + "\n");
				}
				$$.traducao = "\tgoto " + pilhaDeLabels.back().fim + ";\n";
			}
			| TK_CONTINUE ';'
			{
				if(pilhaDeLabels.size() < 1){
					errorFlag = 1;
					errorString += "no loop to continue\nLine: " + to_string(lineNumber) + "\n";
					//yyerror("no loop to continue\nLine: " + to_string(lineNumber) + "\n");
				}
				$$.traducao = "\tgoto " + pilhaDeLabels.back().comeco + ";\n";
			}
			| TK_POWERBREAK ';'
			{
				if(pilhaDeLabels.size() < 1){
					errorFlag = 1;
					errorString += "no loop to powerbreak out of\nLine: " + to_string(lineNumber) + "\n";
					//yyerror("no loop to powerbreak out of\nLine: " + to_string(lineNumber) + "\n");
				}
				$$.traducao = "\tgoto " + pilhaDeLabels.at(0).fim + ";\n";
			}
			| TK_POWERCONTINUE ';'
			{
				if(pilhaDeLabels.size() < 1){
					errorFlag = 1;
					errorString += "no loop to powercontinue\nLine: " + to_string(lineNumber) + "\n";
					//yyerror("no loop to powercontinue\nLine: " + to_string(lineNumber) + "\n");
				}
				$$.traducao = "\tgoto " + pilhaDeLabels.at(0).comeco + ";\n";
			}
			;

STMT		: TK_TIPO TK_ID
			{
				if (isIdDeclared($2.label, 0)){
					errorFlag = 1;
					errorString += "id already declared\nLine: " + to_string(lineNumber) + "\n";
					//yyerror("id already declared\nLine: " + to_string(lineNumber) + "\n");
				}
				$2.tempLabel = nameGen();
				$2.tipo = $1.label;
				addMatrix($2);
				$$.traducao = "";
				declaracoes += "\t" + getRealTipo($2) + " " + $2.tempLabel + ";\n";
			}
			| TK_ID TK_ATRIBUICAO E
			{
				string preTraducao = $3.traducao;
				string atribuicao = "";
				if (isIdDeclared($1.label, 1)){
					$1.tipo = getType($1.label);
					if ($1.tipo != $3.tipo){
						if (ehConversivel($1.tipo, $3.tipo)){
							string novoTemp = nameGen();
							preTraducao = preTraducao + "\t" + $3.tipo + " " + novoTemp + ";\n";
							changeTempName($1.label, novoTemp);
						}
						else{
							errorFlag = 1;
							errorString += "id of type " + $1.tipo + " can not be of type " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n";
							//yyerror("id of type " + $1.tipo + " can not be of type " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n");
						}
					}
					$1.traducao = getTempName($1.label);
					$$.traducao = preTraducao + "\t" + $1.traducao + " = " + $3.label + ";\n";
				}
				else{
					errorFlag = 1;
					errorString += "id not declared\nLine: " + to_string(lineNumber) + "\n";
					//yyerror("id not declared\nLine: " + to_string(lineNumber) + "\n");
				}
			}

E 			: E TK_SOMA E
			{
				switch(ajeitarExpressao($$, $1, $2.label, $3)){
					case -1:
						errorFlag = 1;
						errorString += "no operation of type '+' defined for types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n";
						break;
						//yyerror("no operation of type '+' defined for types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n");
					case -2:
						errorFlag = 1;
						errorString += "cannot convert types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n";
						break;
						//yyerror("cannot convert types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n");
					case 1:
						break;
				}
			}
			| E TK_SUBTRACAO E
			{
				switch(ajeitarExpressao($$, $1, $2.label, $3)){
					case -1:
						errorFlag = 1;
						errorString += "no operation of type '-' defined for types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n";
						break;
						//yyerror("no operation of type '+' defined for types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n");
					case -2:
						errorFlag = 1;
						errorString += "cannot convert types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n";
						break;
						//yyerror("cannot convert types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n");
					case 1:
						break;
				}
			}
			| E TK_DIVISAO E
			{
				switch(ajeitarExpressao($$, $1, $2.label, $3)){
					case -1:
						errorFlag = 1;
						errorString += "no operation of type '/' defined for types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n";
						break;
						//yyerror("no operation of type '+' defined for types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n");
					case -2:
						errorFlag = 1;
						errorString += "cannot convert types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n";
						break;
						//yyerror("cannot convert types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n");
					case 1:
						break;
				}
			}
			| E TK_MULTIPLICACAO E
			{
				switch(ajeitarExpressao($$, $1, $2.label, $3)){
					case -1:
						errorFlag = 1;
						errorString += "no operation of type '*' defined for types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n";
						break;
						//yyerror("no operation of type '+' defined for types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n");
					case -2:
						errorFlag = 1;
						errorString += "cannot convert types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n";
						break;
						//yyerror("cannot convert types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n");
					case 1:
						break;
				}
			}
			| E TK_MENOR E
			{
				switch(ajeitarExpressao($$, $1, $2.label, $3)){
					case -1:
						errorFlag = 1;
						errorString += "no operation of type '<' defined for types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n";
						break;
						//yyerror("no operation of type '+' defined for types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n");
					case -2:
						errorFlag = 1;
						errorString += "cannot convert types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n";
						break;
						//yyerror("cannot convert types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n");
					case 1:
						break;
				}
			}
			| E TK_MAIOR E
			{
				switch(ajeitarExpressao($$, $1, $2.label, $3)){
					case -1:
						errorFlag = 1;
						errorString += "no operation of type '>' defined for types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n";
						break;
						//yyerror("no operation of type '+' defined for types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n");
					case -2:
						errorFlag = 1;
						errorString += "cannot convert types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n";
						break;
						//yyerror("cannot convert types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n");
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
				$$.traducao = "\t" + $$.label + " = " + $1.traducao + ";\n";
				declaracoes += "\t" + getRealTipo($$) + " " + $$.label + ";\n";
				
			}
			| TK_REAL
			{
				$$.label = nameGen();
				$$.tempLabel = $$.label;
				$$.tipo = "float";
				$$.traducao = "\t" + $$.label + " = " + $1.traducao + ";\n";
				declaracoes += "\t" + getRealTipo($$) + " " + $$.label + ";\n";
			}
			| TK_CHAR
			{
				$$.label = nameGen();
				$$.tempLabel = $$.label;
				$$.tipo = "char";
				$$.traducao = "\t" + $$.label + " = " + $1.traducao + ";\n";
				declaracoes += "\t" + getRealTipo($$) + " " + $$.label + ";\n";
			}
			| TK_STRING
			{
				$$.label = nameGen();
				$$.tempLabel = $$.label;
				$$.tipo = "string";
				$$.tamanhoDaString = $1.tamanhoDaString;
				$$.traducao = "\t" + $$.label + " = " + $1.traducao + ";\n";
				declaracoes += "\t" + getRealTipo($$) + " " + $$.label + ";\n";
			}
			| TK_BOOL
			{
				$$.label = nameGen();
				$$.tempLabel = $$.label;
				$$.tipo = "boolean";
				$$.traducao = "\t" + $$.label + " = " + $1.traducao + ";\n";
				declaracoes += "\t" + getRealTipo($$) + " " + $$.label + ";\n";
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
			| TK_ID TK_ATRIBUICAO E
			{
				string preTraducao = $3.traducao;
				string atribuicao = "";
				if (isIdDeclared($1.label, 1)){
					$1.tipo = getType($1.label);
					if ($1.tipo != $3.tipo){
						if (ehConversivel($1.tipo, $3.tipo)){
							string novoTemp = nameGen();
							preTraducao = preTraducao + "\t" + $3.tipo + " " + novoTemp + ";\n";
							changeTempName($1.label, novoTemp);
						}
						else{
							errorFlag = 1;
							errorString += "id of type " + $1.tipo + " can not be of type " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n";
							//yyerror("id of type " + $1.tipo + " can not be of type " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n");
						}
					}
					$1.traducao = getTempName($1.label);
					$$.traducao = preTraducao + "\t" + $1.traducao + " = " + $3.label + ";\n";
				}
				else{
					errorFlag = 1;
					errorString += "id not declared\nLine: " + to_string(lineNumber) + "\n";
					// yyerror("id not declared\nLine: " + to_string(lineNumber) + "\n");
				}
			}
			| TK_ID
			{
				atributos aux = procurarNoEscopo($1.label, 1);
				if(aux.label !=  "NULL"){
					// $$.label = matriz[1][aux];
					// $$.tipo = matriz[2][aux];
					$$ = aux;
					$$.traducao = "";
					$$.label = $$.tempLabel;							//gambiarra
				}
				else{
					errorFlag = 1;
					errorString += "id not declared\nLine: " + to_string(lineNumber) + "\n";
					//yyerror("id not declared\nLine: " + to_string(lineNumber) + "\n");
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
			
