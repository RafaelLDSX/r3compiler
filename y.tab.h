/* A Bison parser, made by GNU Bison 3.0.4.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    TK_SOMA = 258,
    TK_SUBTRACAO = 259,
    TK_DIVISAO = 260,
    TK_MULTIPLICACAO = 261,
    TK_MENOR = 262,
    TK_MAIOR = 263,
    TK_MENORIGUAL = 264,
    TK_MAIORIGUAL = 265,
    TK_ATRIBUICAO = 266,
    TK_IGUAL = 267,
    TK_DIFERENTE = 268,
    TK_COMENTARIO = 269,
    TK_NUM = 270,
    TK_REAL = 271,
    TK_BOOL = 272,
    TK_MAIN = 273,
    TK_ID = 274,
    TK_TIPO = 275,
    TK_FIM = 276,
    TK_ERROR = 277
  };
#endif
/* Tokens.  */
#define TK_SOMA 258
#define TK_SUBTRACAO 259
#define TK_DIVISAO 260
#define TK_MULTIPLICACAO 261
#define TK_MENOR 262
#define TK_MAIOR 263
#define TK_MENORIGUAL 264
#define TK_MAIORIGUAL 265
#define TK_ATRIBUICAO 266
#define TK_IGUAL 267
#define TK_DIFERENTE 268
#define TK_COMENTARIO 269
#define TK_NUM 270
#define TK_REAL 271
#define TK_BOOL 272
#define TK_MAIN 273
#define TK_ID 274
#define TK_TIPO 275
#define TK_FIM 276
#define TK_ERROR 277

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
