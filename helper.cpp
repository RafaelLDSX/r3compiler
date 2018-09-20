#include <iostream>
#include <string>
#include <sstream>
#include <vector>

#define MATRIX_SIZE 10
#define YYSTYPE atributos

using namespace std;

struct atributos
{
	string label;
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

static int contadorMatriz = 0;
static string matriz[3][10];
static int counter = 0;
static vector<OPERACOES> operacoes;

string nameGen(){
	counter++;
	return "tmp" + to_string(counter);

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
	if (searchMatrix(id) != -1){
		return true;
	}
	return false;
}

void addMatrix(atributos n){
	matriz[0][contadorMatriz] = n.label;
	matriz[1][contadorMatriz] = n.traducao;
	matriz[2][contadorMatriz] = n.tipo;
	contadorMatriz++;
}

string getTempName(string s){
	int aux;
	for (aux = 0; matriz[0][aux] != s && aux < contadorMatriz; aux++){

	}
	return matriz[1][aux];
}

void inserirVetorOp(string op, string a, string b, string r){
	OPERACOES aux = {op, a, b, r};
	operacoes.push_back(aux);
}

void criarVetorOp(){
	inserirVetorOp("+", "int", "int", "int");
	inserirVetorOp("+", "int", "float", "float");
	inserirVetorOp("+", "float", "float", "float");

}

void printVetorOp(){
	cout << "\nTabela de Operações\n";
	for(int i = 0; i < 3; i++){
		cout << operacoes[i].tipoA << " ";
		cout << operacoes[i].op << " ";
		cout << operacoes[i].tipoB << " = ";
		cout << operacoes[i].resultado << "\n";
	}
	cout << "\n";
}

string checarOp(string op, string opA, string opB){
	for (int i = 0; i < operacoes.size(); i++){
		if (operacoes[i].op == op){
			if ((operacoes[i].tipoA == opA && operacoes[i].tipoB == opB) || operacoes[i].tipoA == opB && operacoes[i].tipoB == opA){
				return operacoes[i].resultado;
			}
		}
	}
	return "";
}
