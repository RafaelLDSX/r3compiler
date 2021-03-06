#pragma once
#include <iostream>
#include <string>
#include <sstream>
#include <vector>

#define MATRIX_SIZE 10
#define YYSTYPE atributos

using namespace std;

struct labelStruct
{
	string comeco;
	string fim;
};

struct atributos
{
	string label;
	string tempLabel;
	string traducao;
	string tipo;
	int tamanhoDaString;
	string varType;
};

typedef struct ops
{
	string op;
	string tipoA;
	string tipoB;
	string resultado;
} OPERACOES;

struct Conversao
{
	string tipo;
	string tipoConvertido;
};

static int lineNumber = 1;
static int contadorMatriz = 0;
static string matriz[3][MATRIX_SIZE];
static int counter = 0;
static vector<OPERACOES> operacoes;
static vector<Conversao> conversoes;
static vector< vector<atributos> > pilhaDeTabelaDeSimbolos;
static string declaracoes = "";
static string atribucoes = "";
static int labelCounter = 0;
static vector<labelStruct> pilhaDeLabels;
static int errorCounter = 0;
static int errorFlag = 0;
static string errorString = "";

//se for 1 - sem variáveis dinâmicas
//se for 0 - com variáveis dinâmicas
static int strict_mode = 0;

string nameGen();
string labelNameGen();
int searchMatrix(string id);
bool isIdDeclared(string id, int flag);
void addMatrix(atributos n);
int ajeitarExpressao(atributos &resultado, atributos op1, string operador, atributos op2);
bool precisaDeConversao(string opA, string opB);
vector<int> getIdIndex(string id);
string getType(string s);
string getTempName(string s);
string getVarType(string s);
void changeTempName(string id, string novoTemp);
void changeVarType(string id, string novoTipo);
void inserirVetorOp(string op, string a, string b, string r);
void criarVetorOp();
void printVetorOp();
void inserirVetorConversoes(string tipo, string tipoConvertido);
void criarVetorConversoes();
string checarOp(string op, string opA, string opB);
bool ehConversivel(string tipo, string candidato);
int decidirConversao(string opA, string opB);
void criarTabelaDeSimbolos();
void desempilharTabelaDeSimbolos();
void empilharTabelaDeSimbolos(atributos n);
atributos procurarNoEscopo(string n, int flag);
void empilharLabelStruct(string comeco, string fim);
void desempilharLabelStruct();
int contarString(string a);
string getRealTipo(atributos a);
void alterarTamanhoDaString(string id, int tamanho);

//salva mensagem de erro para ser exibida
void flagError(string msg);

string nameGen(){
	counter++;
	return "tmp" + to_string(counter);
}

string labelNameGen(){
	labelCounter++;
	return "label" + to_string(labelCounter);
}

int searchMatrix(string id){
	
	for(int i = 0; i < 10; i++){
		if (matriz[0][i] == id){
			return i; 
		}
	}
	return -1;
}

bool isIdDeclared(string id, int flag){
	// if (searchMatrix(id) != -1){
	// 	return true;
	// }
	// return false;
	atributos aux = procurarNoEscopo(id, flag);
	if (aux.label ==  "NULL"){
		return false;
	}
	return true;
}

void addMatrix(atributos n){
	pilhaDeTabelaDeSimbolos.back().push_back(n);
}

int ajeitarExpressao(atributos &resultado, atributos op1, string operador, atributos op2){
	string realTipo1 = op1.tipo;
	string realTipo2 = op2.tipo;
	if(realTipo1 == "var"){
		realTipo1 = getVarType(op1.label);
	}
	if(realTipo2 == "var"){
		realTipo2 = getVarType(op2.label);
	}
	resultado.tipo = checarOp(operador, realTipo1, realTipo2);
	if (resultado.tipo == ""){
		return -1;
	}
	resultado.label = nameGen();
	resultado.tempLabel = resultado.label;

	//declaração e calculo dos operandos que serão utilizados
	resultado.traducao = op1.traducao + op2.traducao;
	declaracoes += "\t" + resultado.tipo + " " + resultado.label + ";\n";

	//operação propriamente dita
	string operacao = "\t" + resultado.label + " = " + op1.tempLabel + " " + operador + " " + op2.tempLabel + ";\n";

	string conversao = "";

	string aux;

	//se for necessaria a conversao de um dos operandos
	if (precisaDeConversao(realTipo1, realTipo2)){
		switch(decidirConversao(realTipo1, realTipo2)){
			case 1:
				aux = nameGen();
				conversao = "\t" + resultado.tipo + " " + aux + " = (" + resultado.tipo + ") " + op1.tempLabel + ";\n";
				operacao = "\t" + resultado.label + " = " + aux + " " + operador + " " + op2.tempLabel + ";\n";
				break;
			case 2:
				aux = nameGen();
				conversao = "\t" + resultado.tipo + " " + aux + " = (" + resultado.tipo + ") " + op2.tempLabel + ";\n";
				operacao = "\t" + resultado.label + " = " + op1.tempLabel + " " + operador + " " + aux + ";\n";
				break;
			case 0:
				return -2;
		}
		if (op1.tipo != resultado.tipo){
			string aux = nameGen();
			conversao = "\t" + resultado.tipo + " " + aux + " = (" + resultado.tipo + ") " + op1.tempLabel + ";\n";
			operacao = "\t" + resultado.label + " = " + aux + " " + operador + " " + op2.tempLabel + ";\n";
		}
		else{
			string aux = nameGen();
			conversao = "\t" + resultado.tipo + " " + aux + " = (" + resultado.tipo + ") " + op2.tempLabel + ";\n";
			operacao = "\t" + resultado.label + " = " + op1.tempLabel + " " + operador + " " + aux + ";\n";
		}
	}
	resultado.traducao = resultado.traducao + conversao + operacao;
	return 1;
}

vector<int> getIdIndex(string id){
	vector<atributos> aux;
	vector<int> retorno;
	int fim;
	for(fim = pilhaDeTabelaDeSimbolos.size() - 1; fim >= 0; fim--){
		aux = pilhaDeTabelaDeSimbolos.at(fim);
		for(int i = 0; i < aux.size(); i++){
			if(aux[i].label == id){
				retorno.push_back(i);
				retorno.push_back(fim);
				return retorno;
			}
		}
	}
	return retorno;
}

string getType(string id){
	atributos aux = procurarNoEscopo(id, 1);
	return aux.tipo;
}

string getTempName(string id){
	atributos aux = procurarNoEscopo(id, 1);
	return aux.tempLabel;
}

void changeTempName(string id, string novoTemp){
	vector<int> aux = getIdIndex(id);
	pilhaDeTabelaDeSimbolos.at(aux.at(1)).at(aux.at(0)).tempLabel = novoTemp;

}

void inserirVetorOp(string op, string a, string b, string r){
	OPERACOES aux = {op, a, b, r};
	operacoes.push_back(aux);
}

void criarVetorOp(){
	//operações de soma
	inserirVetorOp("+", "int", "int", "int");
	inserirVetorOp("+", "int", "float", "float");
	inserirVetorOp("+", "float", "float", "float");
	//operações de subtração
	inserirVetorOp("-", "int", "int", "int");
	inserirVetorOp("-", "int", "float", "float");
	inserirVetorOp("-", "float", "float", "float");
	//operações de divisao
	inserirVetorOp("/", "int", "int", "int");
	inserirVetorOp("/", "int", "float", "float");
	inserirVetorOp("/", "float", "float", "float");
	//operações de multiplicação
	inserirVetorOp("*", "int", "int", "int");
	inserirVetorOp("*", "int", "float", "float");
	inserirVetorOp("*", "float", "float", "float");
	//relacionais
	inserirVetorOp(">", "int", "int", "boolean");
	inserirVetorOp(">", "int", "float", "boolean");
	inserirVetorOp(">", "float", "float", "boolean");
	inserirVetorOp("<", "int", "int", "boolean");
	inserirVetorOp("<", "int", "float", "boolean");
	inserirVetorOp("<", "float", "float", "boolean");


}

void printVetorOp(){
	cout << "\nTabela de Operações\n";
	for(int i = 0; i < operacoes.size(); i++){
		cout << operacoes[i].tipoA << " ";
		cout << operacoes[i].op << " ";
		cout << operacoes[i].tipoB << " = ";
		cout << operacoes[i].resultado << "\n";
	}
	cout << "\n";
}

void inserirVetorConversoes(string tipo, string tipoConvertido){
	Conversao aux = {tipo, tipoConvertido};
	conversoes.push_back(aux);
}

void criarVetorConversoes(){
	inserirVetorConversoes("int", "float");
}

string checarOp(string op, string opA, string opB){
	for (int i = 0; i < operacoes.size(); i++){
		if (operacoes[i].op == op){
			//por ter apenas um na tabela, checa-se também trocando a ordem dos operadores
			if ((operacoes[i].tipoA == opA && operacoes[i].tipoB == opB) || operacoes[i].tipoA == opB && operacoes[i].tipoB == opA){
				return operacoes[i].resultado;
			}
		}
	}
	return "";
}

bool precisaDeConversao(string opA, string opB){
	if (opA != opB){
		return true;
	}
	return false;
}

bool ehConversivel(string tipo, string candidato){
	for (int i = 0; i < conversoes.size(); i++){
		if (tipo == conversoes[i].tipo && candidato == conversoes[i].tipoConvertido){
			return true;
		}
	}
	return false;
}

int decidirConversao(string opA, string opB){
	if (ehConversivel(opA, opB)){
		return 1;
	}
	else if (ehConversivel(opB, opA)){
		return 2;
	}
	else{
		return 0;
	}
}

void criarTabelaDeSimbolos(){
	vector<atributos> table;
	pilhaDeTabelaDeSimbolos.push_back(table);
}

void empilharTabelaDeSimbolos(atributos n){
	pilhaDeTabelaDeSimbolos.back().push_back(n);
}

atributos procurarNoEscopo(string n, int flag){
	int fim;
	vector<atributos> aux;
	//se flag = 1, procura em todas as tabelas de simbolos
	if(flag){
		for(fim = pilhaDeTabelaDeSimbolos.size() - 1; fim >= 0; fim--){
			aux = pilhaDeTabelaDeSimbolos.at(fim);
			for(int i = 0; i < aux.size(); i++){
				if(aux[i].label == n){
					return aux.at(i);
				}
			}
		}
	}
	//se nao, procura somente na atual (caso de declaração de variavel)
	else{
		aux = pilhaDeTabelaDeSimbolos.back();
		for(int i = 0; i < aux.size(); i++){
			if(aux[i].label == n){
				return aux.at(i);
			}
		}
	}
	atributos aux2 = {"NULL", "NULL", "NULL", "NULL"};	
	return aux2;
}

void desempilharTabelaDeSimbolos(){
	pilhaDeTabelaDeSimbolos.pop_back();
}

void empilharLabelStruct(string comeco, string fim){
	labelStruct aux;
	aux.comeco = comeco;
	aux.fim = fim;
	pilhaDeLabels.push_back(aux);
}

void desempilharLabelStruct(){
	pilhaDeLabels.pop_back();
}

int contarString(string a){
	int contador = 0;
	for(string::iterator i = a.begin(); i != a.end(); i++){
		contador++;
	};
	return contador - 1;	//subtraindo aspas e somando EOF
}

string getRealTipo(atributos a){
	if(a.tipo == "boolean"){
		return "int";
	}
	if(a.tipo == "string"){
		return "char*";
	}
	if(a.tipo == "var"){
		return getVarType(a.label);
	}
	else{
		return a.tipo;
	}
}

void flagError(string msg){
	errorFlag = 1;
	errorString += msg;
	errorCounter++;
}

void alterarTamanhoDaString(string id, int tamanho){
	vector<int> aux = getIdIndex(id);
	pilhaDeTabelaDeSimbolos.at(aux.at(1)).at(aux.at(0)).tamanhoDaString = tamanho;
}

void changeVarType(string id, string novoTipo){
	vector<int> aux = getIdIndex(id);
	pilhaDeTabelaDeSimbolos.at(aux.at(1)).at(aux.at(0)).varType = novoTipo;
}

string getVarType(string id){
	atributos aux = procurarNoEscopo(id, 1);
	return aux.varType;
}
