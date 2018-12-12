%{
#include <iostream>
#include <string>
#include <sstream>
#include "helper.cpp"


using namespace std;



int yylex(void);
void yyerror(string);
%}

%token TK_STRICT
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
//add regra vazia no strict que vai funfar!
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
			| EMPTYSTRICT TK_STRICT S
			{
				$$.traducao = "";
			}
			;
EMPTYSTRICT	:
			{
				strict_mode = 1;
			}
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
					flagError("expression is not boolean");
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

			}
			| TK_BREAK ';'
			{
				if(pilhaDeLabels.size() < 1){
					flagError("no loop to break out of\nLine: " + to_string(lineNumber) + "\n");
					//yyerror("no loop to break out of\nLine: " + to_string(lineNumber) + "\n");
				}
				$$.traducao = "\tgoto " + pilhaDeLabels.back().fim + ";\n";
			}
			| TK_CONTINUE ';'
			{
				if(pilhaDeLabels.size() < 1){
					flagError("no loop to continue\nLine: " + to_string(lineNumber) + "\n");
					//yyerror("no loop to continue\nLine: " + to_string(lineNumber) + "\n");
				}
				$$.traducao = "\tgoto " + pilhaDeLabels.back().comeco + ";\n";
			}
			| TK_POWERBREAK ';'
			{
				if(pilhaDeLabels.size() < 1){
					flagError("no loop to powerbreak out of\nLine: " + to_string(lineNumber) + "\n");
					//yyerror("no loop to powerbreak out of\nLine: " + to_string(lineNumber) + "\n");
				}
				$$.traducao = "\tgoto " + pilhaDeLabels.at(0).fim + ";\n";
			}
			| TK_POWERCONTINUE ';'
			{
				if(pilhaDeLabels.size() < 1){
					flagError("no loop to powercontinue\nLine: " + to_string(lineNumber) + "\n");
					//yyerror("no loop to powercontinue\nLine: " + to_string(lineNumber) + "\n");
				}
				$$.traducao = "\tgoto " + pilhaDeLabels.at(0).comeco + ";\n";
			}
			;

STMT		: TK_TIPO TK_ID
			{
				if (isIdDeclared($2.label, 0)){
					flagError("id already declared\nLine: " + to_string(lineNumber) + "\n");
					//yyerror("id already declared\nLine: " + to_string(lineNumber) + "\n");
				}
				$2.tempLabel = nameGen();
				$2.tipo = $1.label;
				$$.traducao = "";
				string aux = getRealTipo($2);
				//se a variável for do tipo 'var', declara inicialmente no código intermediário como 'int'
				if($2.tipo == "var"){
					aux = "int";
					$2.varType = "int";
				}
				addMatrix($2);
				declaracoes += "\t" + aux + " " + $2.tempLabel + ";\n";
			}
			| TK_ID TK_ATRIBUICAO E
			{
				string preTraducao = $3.traducao;
				string atribuicao = "";
				if (isIdDeclared($1.label, 1)){
					$1.tipo = getType($1.label);
					if ($1.tipo != $3.tipo && $1.tipo != "var"){ //corrigir o caso de $3.tipo ser 'var'
						if($1.tipo == getRealTipo($3)){

						}
						else{
							if (ehConversivel($1.tipo, $3.tipo)){
								string novoTemp = nameGen();
								preTraducao = preTraducao + "\t" + $3.tipo + " " + novoTemp + ";\n";
								changeTempName($1.label, novoTemp);
							}
							else{
								flagError("id of type " + $1.tipo + " can not be of type " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n");
								//yyerror("id of type " + $1.tipo + " can not be of type " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n");
							}
						}
						
					}
					if($1.tipo == "var"){
						string tipoDaVariavel = getRealTipo($1);
						string tipoDaExpressao = getRealTipo($3);
						//se os tipos não forem iguais, converter o var
						if(tipoDaVariavel != tipoDaExpressao){
							string newName = nameGen();
							preTraducao = preTraducao + "\t" + tipoDaExpressao + " " + newName + ";\n";
							changeTempName($1.label, newName);
							changeVarType($1.label, tipoDaExpressao);
						}
					}
					$1.traducao = getTempName($1.label);
					if($1.tipo == "string" || $3.tipo == "string"){
						$1.tamanhoDaString = $3.tamanhoDaString;
						alterarTamanhoDaString($1.label, $1.tamanhoDaString);
						$$.traducao = preTraducao + "\t" + $1.traducao + " = (" + getRealTipo($1) + ") malloc(" 
							+ to_string($1.tamanhoDaString) + ");\n" 
							+ "\tstrcpy(" + $1.traducao + ", " + $3.tempLabel + ");\n"
							+ "\tfree(" + $3.tempLabel + ");\n"; 
					}
					else{
						$$.traducao = preTraducao + "\t" + $1.traducao + " = " + $3.tempLabel + ";\n";
					}
				}
				else{
					if(strict_mode == 1){
						flagError("id not declared\nLine: " + to_string(lineNumber) + "\n");	
					}
					//inferindo o tipo
					$1.tipo = $3.tipo;
					$1.tempLabel = nameGen();
					addMatrix($1);
					if($1.tipo == "string"){
						$1.tamanhoDaString = $3.tamanhoDaString;
						alterarTamanhoDaString($1.label, $1.tamanhoDaString);
						$$.traducao = preTraducao + "\t" + $1.tempLabel + " = (" + getRealTipo($1) + ") malloc(" 
							+ to_string($1.tamanhoDaString) + ");\n" 
							+ "\tstrcpy(" + $1.tempLabel + ", " + $3.tempLabel + ");\n"
							+ "\tfree(" + $3.tempLabel + ");\n";
					}
					else{
						$$.traducao = preTraducao + "\t" + $1.tempLabel + " = " + $3.tempLabel + ";\n";
					}
					string aux = getRealTipo($1);
					declaracoes += "\t" + aux + " " + $1.tempLabel + ";\n";
					// yyerror("id not declared\nLine: " + to_string(lineNumber) + "\n");
				}
			}

E 			: E TK_SOMA E
			{
				switch(ajeitarExpressao($$, $1, $2.label, $3)){
					case -1:
						flagError("no operation of type '+' defined for types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n");
						break;
						//yyerror("no operation of type '+' defined for types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n");
					case -2:
						flagError("cannot convert types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n");
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
						flagError("no operation of type '-' defined for types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n");
						break;
						//yyerror("no operation of type '+' defined for types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n");
					case -2:
						flagError("cannot convert types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n");
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
						flagError("no operation of type '/' defined for types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n");
						break;
						//yyerror("no operation of type '+' defined for types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n");
					case -2:
						flagError("cannot convert types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n");
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
						flagError("no operation of type '*' defined for types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n");
						break;
						//yyerror("no operation of type '+' defined for types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n");
					case -2:
						flagError("cannot convert types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n");
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
						flagError("no operation of type '<' defined for types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n");
						break;
						//yyerror("no operation of type '+' defined for types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n");
					case -2:
						flagError("cannot convert types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n");
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
						flagError("no operation of type '>' defined for types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n");
						break;
						//yyerror("no operation of type '+' defined for types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n");
					case -2:
						flagError("cannot convert types " + $1.tipo + " and " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n");
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
				string aux = getRealTipo($$);
				$$.traducao = "\t" + $$.label + " = (" + aux + ") malloc(" + to_string($$.tamanhoDaString) + ")\n\tstrcpy(" + $$.label + ", " + $1.traducao + ");\n";
				declaracoes += "\t" + aux + " " + $$.label + ";\n";
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
				if(!(ehConversivel(getType($4.label), $2.label))){
					flagError("cannot convert " + $4.tipo + " into " + $2.label);
				}
				else{
					$$.traducao = "";
					$$.label = nameGen();
					$$.tempLabel = $$.label;
					$$.tipo = $2.label;
					$$.traducao = "";
					declaracoes += "\t" + $$.tipo + " " + $$.label + " = " + $1.traducao + ";\n";
					addMatrix($$);
				}
			}
			| TK_ID TK_ATRIBUICAO E
			{
				string preTraducao = $3.traducao;
				string atribuicao = "";
				string realTipo3 = $3.tipo;
				if (isIdDeclared($1.label, 1)){
					$1.tipo = getType($1.label);
					if ($1.tipo != $3.tipo && $1.tipo != "var"){
						if($3.tipo == "var"){
							realTipo3 = getVarType($3.label);
						}
						if (ehConversivel($1.tipo, realTipo3)){
							string novoTemp = nameGen();
							preTraducao = preTraducao + "\t" + $3.tipo + " " + novoTemp + ";\n";
							changeTempName($1.label, novoTemp);
						}
						else{
							flagError("id of type " + $1.tipo + " can not be of type " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n");
							//yyerror("id of type " + $1.tipo + " can not be of type " + $3.tipo + "\nLine: " + to_string(lineNumber) + "\n");
						}
					}
					if($1.tipo == "var"){
						string tipoDaVariavel = getRealTipo($1);
						string tipoDaExpressao = getRealTipo($3);
						//se os tipos não forem iguais, converter o var
						if(tipoDaVariavel != tipoDaExpressao){
							string newName = nameGen();
							preTraducao = preTraducao + "\t" + tipoDaExpressao + " " + newName + ";\n";
							changeTempName($1.label, newName);
							changeVarType($1.label, tipoDaExpressao);
						}
					}
					$1.traducao = getTempName($1.label);
					if($1.tipo == "string" || $3.tipo == "string"){
						$1.tamanhoDaString = $3.tamanhoDaString;
						alterarTamanhoDaString($1.label, $1.tamanhoDaString);
						$$.traducao = preTraducao + "\t" + $1.traducao + " = (" + getRealTipo($1) + ") malloc(" 
							+ to_string($1.tamanhoDaString) + ");\n" 
							+ "\tstrcpy(" + $1.traducao + ", " + $3.tempLabel + ");\n"
							+ "\tfree(" + $3.tempLabel + ");\n"; 
					}
					else{
						$$.traducao = preTraducao + "\t" + $1.traducao + " = " + $3.tempLabel + ";\n";
					}
				}
				else{
					if(strict_mode == 1){
						flagError("id not declared\nLine: " + to_string(lineNumber) + "\n");	
					}
					//inferindo o tipo
					$1.tipo = $3.tipo;
					$1.tempLabel = nameGen();
					addMatrix($1);
					if($1.tipo == "string"){
						$1.tamanhoDaString = $3.tamanhoDaString;
						alterarTamanhoDaString($1.label, $1.tamanhoDaString);
						$$.traducao = preTraducao + "\t" + $1.tempLabel + " = (" + getRealTipo($1) + ") malloc(" 
							+ to_string($1.tamanhoDaString) + ");\n" 
							+ "\tstrcpy(" + $1.tempLabel + ", " + $3.tempLabel + ");\n"
							+ "\tfree(" + $3.tempLabel + ");\n";
					}
					else{
						$$.traducao = preTraducao + "\t" + $1.tempLabel + " = " + $3.tempLabel + ";\n";
					}
					string aux = getRealTipo($1);
					declaracoes += "\t" + aux + " " + $1.tempLabel + ";\n";
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
					//$$.label = $$.tempLabel;							//gambiarra
				}
				else{
					flagError("id not declared\nLine: " + to_string(lineNumber) + "\n");
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
			
