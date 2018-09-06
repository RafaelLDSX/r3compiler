#include <iostream>
#include <string>
#include <sstream>

#define MATRIX_SIZE 10

using namespace std;

static int contadorMatriz = 0;
static string matriz[3][10];
static int counter = 0;

string nameGen(){
	counter++;
	return "tmp" + to_string(counter);

}

int searchMatrix(string id){
	
	for(int i = 0; i < 10; i++){
		matriz[i][0] == id;
		return i; 
	}
	return -1;
}