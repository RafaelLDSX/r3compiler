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
static int labelCounter = 0;
static vector<labelStruct> pilhaDeLabels;

string nameGen();
string labelNameGen();
int searchMatrix(string id);
bool isIdDeclared(string id);
void addMatrix(atributos n);
int ajeitarExpressao(atributos &resultado, atributos op1, string operador, atributos op2);
bool precisaDeConversao(string opA, string opB);
int getIdIndex(string id);
string getType(string s);
string getTempName(string s);
void changeTempName(string tipo);
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
atributos procurarNoEscopo(string n);
void empilharLabelStruct(string comeco, string fim);
void desempilharLabelStruct();

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

bool isIdDeclared(string id){
	// if (searchMatrix(id) != -1){
	// 	return true;
	// }
	// return false;
	atributos aux = procurarNoEscopo(id);
	if (aux.label ==  "NULL"){
		return false;
	}
	return true;
}

void addMatrix(atributos n){
	// matriz[0][contadorMatriz] = n.label;
	// matriz[1][contadorMatriz] = n.traducao;
	// matriz[2][contadorMatriz] = n.tipo;
	// contadorMatriz++;
	pilhaDeTabelaDeSimbolos.back().push_back(n);
}

int ajeitarExpressao(atributos &resultado, atributos op1, string operador, atributos op2){
	resultado.tipo = checarOp(operador, op1.tipo, op2.tipo);
	if (resultado.tipo == ""){
		return -1;
	}
	resultado.label = nameGen();
	resultado.tempLabel = resultado.label;

	//declaração e calculo dos operandos que serão utilizados
	resultado.traducao = op1.traducao + op2.traducao;
	declaracoes += "\t" + resultado.tipo + " " + resultado.label + ";\n";

	//operação propriamente dita
	string operacao = "\t" + resultado.label + " = " + op1.label + " " + operador + " " + op2.label + ";\n";

	string conversao = "";

	string aux;

	//se for necessaria a conversao de um dos operandos
	if (precisaDeConversao(op1.tipo, op2.tipo)){
		switch(decidirConversao(op1.tipo, op2.tipo)){
			case 1:
				aux = nameGen();
				conversao = "\t" + resultado.tipo + " " + aux + " = (" + resultado.tipo + ") " + op1.label + ";\n";
				operacao = "\t" + resultado.label + " = " + aux + " " + operador + " " + op2.label + ";\n";
				break;
			case 2:
				aux = nameGen();
				conversao = "\t" + resultado.tipo + " " + aux + " = (" + resultado.tipo + ") " + op2.label + ";\n";
				operacao = "\t" + resultado.label + " = " + op1.label + " " + operador + " " + aux + ";\n";
				break;
			case 0:
				return -2;
		}
		if (op1.tipo != resultado.tipo){
			string aux = nameGen();
			conversao = "\t" + resultado.tipo + " " + aux + " = (" + resultado.tipo + ") " + op1.label + ";\n";
			operacao = "\t" + resultado.label + " = " + aux + " " + operador + " " + op2.label + ";\n";
		}
		else{
			string aux = nameGen();
			conversao = "\t" + resultado.tipo + " " + aux + " = (" + resultado.tipo + ") " + op2.label + ";\n";
			operacao = "\t" + resultado.label + " = " + op1.label + " " + operador + " " + aux + ";\n";
		}
	}
	resultado.traducao = resultado.traducao + conversao + operacao;
	return 1;
}

int getIdIndex(string id){
	int aux;
	for (aux = 0; matriz[0][aux] != id && aux < contadorMatriz; aux++){}
	if (aux < contadorMatriz){
		return aux;
	}
	return -1;
}

string getType(string id){
	atributos aux = procurarNoEscopo(id);
	return aux.tipo;
}

string getTempName(string id){
	atributos aux = procurarNoEscopo(id);
	return aux.tempLabel;
}

void changeTempName(string id, string tipo){
	int aux = getIdIndex(id);
	matriz[1][aux] = tipo;

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

atributos procurarNoEscopo(string n){
	int fim;
	vector<atributos> aux;
	for(fim = pilhaDeTabelaDeSimbolos.size() - 1; fim >= 0; fim--){
		aux = pilhaDeTabelaDeSimbolos.at(fim);
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
