/* A Bison parser, made by GNU Bison 2.3.  */

/* Skeleton interface for Bison's Yacc-like parsers in C

   Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02110-1301, USA.  */

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

/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     PROG = 258,
     PERIOD = 259,
     VAR = 260,
     INT = 261,
     BOOL = 262,
     ARRAY = 263,
     RANGE = 264,
     OF = 265,
     WRITELN = 266,
     THEN = 267,
     IF = 268,
     BEG = 269,
     END = 270,
     ASG = 271,
     DO = 272,
     FOR = 273,
     EQ = 274,
     NEQ = 275,
     LT = 276,
     LEQ = 277,
     AND = 278,
     OR = 279,
     XOR = 280,
     NOT = 281,
     TRUE = 282,
     FALSE = 283,
     ELSE = 284,
     WHILE = 285,
     ID = 286,
     ICONST = 287
   };
#endif
/* Tokens.  */
#define PROG 258
#define PERIOD 259
#define VAR 260
#define INT 261
#define BOOL 262
#define ARRAY 263
#define RANGE 264
#define OF 265
#define WRITELN 266
#define THEN 267
#define IF 268
#define BEG 269
#define END 270
#define ASG 271
#define DO 272
#define FOR 273
#define EQ 274
#define NEQ 275
#define LT 276
#define LEQ 277
#define AND 278
#define OR 279
#define XOR 280
#define NOT 281
#define TRUE 282
#define FALSE 283
#define ELSE 284
#define WHILE 285
#define ID 286
#define ICONST 287




#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
#line 15 "parse.y"
{tokentype token;
        regInfo targetReg;
        
        }
/* Line 1529 of yacc.c.  */
#line 118 "parse.tab.h"
	YYSTYPE;
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif

extern YYSTYPE yylval;

