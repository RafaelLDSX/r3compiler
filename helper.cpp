#include <iostream>
#include <string>
#include <sstream>

using namespace std;

static int counter = 0;

string nameGen(){
	counter++;
	return "tmp" + to_string(counter);

}