#include <iostream>
#include <string>
#include <sstream>

#define MATRIX_SIZE 10
#define YYSTYPE atributos

using namespace std;

struct atributos
{
	string label;
	string traducao;
	string tipo;
};

static int contadorMatriz = 0;
static string matriz[3][10];
static int counter = 0;

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
