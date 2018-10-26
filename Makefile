all: 	
		clear
		lex lexica.l
		yacc -d sintatica.y
		g++ -std=c++11 -o glf y.tab.c

		./glf < testefile.r3
