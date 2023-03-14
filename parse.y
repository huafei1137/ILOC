%{
#include <stdio.h>
#include <stdlib.h>
#include "attr.h"
#include "instrutil.h"
int yylex();
void yyerror(char * s);
#include "symtab.h"

FILE *outfile;
char *CommentBuffer;

%}

%union {tokentype token;
        regInfo targetReg;
        
        }

%token PROG PERIOD VAR 
%token INT BOOL ARRAY RANGE OF WRITELN THEN IF 
%token BEG END ASG DO FOR
%token EQ NEQ LT LEQ 
%token AND OR XOR NOT TRUE FALSE 
%token ELSE
%token WHILE 
%token <token> ID ICONST 

%type <targetReg> exp lvalue condexp ifhead astmt ifstmt 

%start program

%nonassoc EQ NEQ LT LEQ 
%left '+' '-' 
%left '*' 
// if then if then else 
%nonassoc THEN
%nonassoc ELSE
// Else high priority (if then (if then) else)
/* %left ELSE */
%%
program : {emitComment("Assign STATIC_AREA_ADDRESS to register \"r0\"");
           //emit(NOLABEL, LOADI, STATIC_AREA_ADDRESS, 0, EMPTY); 
           } 
           PROG ID ';' block PERIOD { }
	;

block	: variables cmpdstmt { }
	;

variables: /* empty */
	| VAR vardcls { }
	;

vardcls	: vardcls vardcl ';' { }
	| vardcl ';' { }
	| error ';' { yyerror("***Error: illegal variable declaration\n");}  
	;

vardcl	: idlist ':' INT { 
                
                } /* incorrect rule */
	;

idlist	: idlist ',' ID {

                int currentvalue = get($3.str);
                if (currentvalue == -1){
                        //NextOffset(4);
                        int offset = NextOffset();
                        insert( $3.str, offset);
                        currentvalue = get($3.str);
                }
                currentvalue += STATIC_AREA_ADDRESS;
                // insert(mymap, "a", 1);
                sprintf(CommentBuffer, "using the hashmap we can find the address of \" %s  \"  %d", $3.str,currentvalue);
                emitComment(CommentBuffer);
 }
	| ID		{
                //int offset = NextOffset();
                int currentvalue = get($1.str);
                if (currentvalue == -1){
                        //NextOffset(4);
                        int offset = NextOffset();
                        insert( $1.str, offset);
                        currentvalue = get($1.str);
                }
                currentvalue += STATIC_AREA_ADDRESS;
                // insert(mymap, "a", 1);
                sprintf(CommentBuffer, "using the hashmap we can find the address of \" %s  \"  %d", $1.str,currentvalue);
                emitComment(CommentBuffer);
                
                
         }
	;

stmtlist : stmtlist ';' stmt { }
	| stmt { }
        | error { yyerror("***Error: wrong statentlist \n");} 
	;

stmt    : ifstmt { 
}     
	| wstmt { }
	| fstmt { }
	| astmt { }
	| writestmt { }
	| cmpdstmt { }
        | error { yyerror("***Error: wrong statement \n");} 
	;

cmpdstmt: BEG stmtlist END { }
	;

/* ifstmt :  ifhead THEN stmt 
        {
         emit(NOLABEL,BR,$1.elselabel,EMPTY,EMPTY);
         emit($1.elselabel,NOP,EMPTY,EMPTY,EMPTY);
        emitComment("if then");
        }
        | 
        ifhead THEN stmt ELSE  stmt {

                emitComment("if then and else");
        }
        | error { yyerror("***Error: if error \n");}
	; */

 ifstmt :  
        ifhead 
        THEN    
        stmt 
        {
                // emit(NOLABEL, CBR, $1.targetRegister, $1.thenlabel, $1.exitlabel);
                emit(NOLABEL,BR,$1.elselabel,EMPTY,EMPTY);
                emit($1.elselabel,NOP,EMPTY,EMPTY,EMPTY);
                emitComment("This is the \"false\" branch");

        } 
        
        |
         ifhead 
                // // int thenlabel = NextLabel();
                // // int elselabel = NextLabel();
                // // int exitlabel = NextLabel();
                // // $$.exitlabel = exitlabel;
                // // $$.elselabel = elselabel;
                // // $$.thenlabel = thenlabel;
                // emit(NOLABEL, CBR, $1.targetRegister, $1.thenlabel, $1.elselabel);
                // emit($1.thenlabel, NOP, EMPTY, EMPTY, EMPTY);
                // emitComment("This is the \"true\" branch");
                // sprintf(CommentBuffer, "previous exit of label should be \" l  \"  %d", $1.exitlabel);
                // //$$.exitlabel = exitlabel;
                // emitComment(CommentBuffer);
        THEN stmt
                // //  int exitlabel = $<targetReg>2.exitlabel;
                // //  int elselabel = $<targetReg>2.elselabel;
                //  sprintf(CommentBuffer, "else of label should be \" l  \"  %d", $1.elselabel);
                //  emitComment(CommentBuffer);
                //  emit(NOLABEL,BR,$1.exitlabel,EMPTY,EMPTY);
                //  emit($1.elselabel,NOP,EMPTY,EMPTY,EMPTY);
                //  emitComment("This is the \"false\" branch");   
        ELSE {

                 sprintf(CommentBuffer, "then label should be \" l  \"  %d", $1.elselabel);
                 emitComment(CommentBuffer);
                 emit(NOLABEL,BR,$1.exitlabel,EMPTY,EMPTY);
                 emit($1.elselabel,NOP,EMPTY,EMPTY,EMPTY);
                 emitComment("This is the \"false\" branch"); 

        } 
        stmt {
                 sprintf(CommentBuffer, "else label should be \" l  \"  %d", $1.exitlabel);
                 emitComment(CommentBuffer);
                 emit(NOLABEL,BR,$1.exitlabel,EMPTY,EMPTY);
                 emit($1.exitlabel,NOP,EMPTY,EMPTY,EMPTY);


        }; 



ifhead : IF condexp 

         { 
        emitComment("This is the \"true\" branch");
       // int newlabel = NextLabel();
        $$.thenlabel = NextLabel();
        $$.elselabel = NextLabel();
        $$.exitlabel = NextLabel();
        $$.targetRegister = $2.targetRegister;
        emit(NOLABEL,CBR,$2.targetRegister,$$.thenlabel,$$.elselabel);
        emit($$.thenlabel,NOP,EMPTY,EMPTY,EMPTY);
        } 
        | error { yyerror("***Error: if head error \n");}
        
        ;

writestmt: WRITELN '(' exp ')' { 
        //if output 1024, then we should start from 1028, we need to modified nextregister(), 
        sprintf(CommentBuffer, "output variable \"r%s\" ", $3.name);
	emitComment(CommentBuffer);
        //emit(NOLABEL,STORE,$3.targetRegister,0,EMPTY);
        //corner case: if the variable is not find, then we should print out the error:
        //int memoryaddress = get($3.name)+STATIC_AREA_ADDRESS; 
        int newReg = NextRegister();
        emit(NOLABEL,LOADI,STATIC_OUTPUT_ADDRESS,newReg,EMPTY);
        emit(NOLABEL,STORE,$3.targetRegister,newReg,EMPTY);
        emit(NOLABEL,OUTPUT,STATIC_OUTPUT_ADDRESS,EMPTY,EMPTY);

}
        //emitComment("output statement");
	;
//stmt : ifstmt | non-if-stmt 
wstmt	: WHILE  
          { emitComment("Control code for \"WHILE DO\"");}
          condexp 
          { emitComment("Body of \"WHILE\" construct starts here");}
          DO stmt  { }
	;

//  for i := 1, 100 do
// then ID a 
//   a = 1;
//   
fstmt : FOR ID ASG ICONST ',' ICONST DO astmt {


        }
	;

astmt : lvalue ASG exp { emitComment("assign statement"); // a ($1.register) := 2 ($3.register)
                // int newReg = NextRegister();
                // $1.targetRegister = newReg; 
                sprintf(CommentBuffer, "assign statement with lvalue to register r%d  ", $1.targetRegister);
                emitComment(CommentBuffer);  
                emit(NOLABEL, STORE, $3.targetRegister, $1.targetRegister, EMPTY);
                //store 12 -> 1024

                // STORE $3 -> $1 
                // exp 2 -> 1028
 }
	;

lvalue	: ID {  // a Map a NextOffset(4), 
               // lvalue -> id
                int newReg = NextRegister();
                
                int memoryaddress = get($1.str)+STATIC_AREA_ADDRESS;
                sprintf(CommentBuffer, "var statement left is  \" r%s  \" ,based on the hashmap the address is %d", $1.str,memoryaddress);
                emitComment(CommentBuffer);
                
                // a -> 1024

                // LoadI 1028 -> newReg r2
                emit(NOLABEL, LOADI, memoryaddress, newReg, EMPTY);
                // newreg -> 1028
                // newreg -> 2
                //int newReg2 = NextRegister();
                //emit(NOLABEL,LOAD,newReg,newReg2,EMPTY);
                $$.targetRegister = newReg;
                $$.name = $1.str;

                // int newReg = NextRegister();
                // //$$.targetRegister = newReg;
                // //int offset = ('A' - $1.str) + 4
                // int offset = (atoi($1.str)+1)*4;
                // sprintf(CommentBuffer, "load left ID  \" r%s  \"  to new register with offset %d", $1.str,offset);
                // emitComment(CommentBuffer);
                // emit(NOLABEL, LOADAI, 0, offset, newReg);
                //return 1028;




}
        |  ID '[' exp ']' { }
        ;

exp	: exp '+' exp		{ int newReg = NextRegister();
                                  $$.targetRegister = newReg;
                                  emit(NOLABEL, 
                                       ADD, 
                                       $1.targetRegister, 
                                       $3.targetRegister, 
                                       newReg);
                                }

        | exp '-' exp		{ int newReg = NextRegister(); 
                                  $$.targetRegister = newReg;
                                  emit(NOLABEL, 
                                       SUB, 
                                       $1.targetRegister, 
                                       $3.targetRegister, 
                                       newReg);
                                }

	| exp '*' exp		{ int newReg = NextRegister(); 
                                  $$.targetRegister = newReg;
                                  emit(NOLABEL, 
                                       MULT, 
                                       $1.targetRegister, 
                                       $3.targetRegister, 
                                       newReg);
                                }

        | ID			{ 
                                  //int newReg = NextRegister();
	                          //$$.targetRegister = newReg;
			          //sprintf(CommentBuffer, "Bogus load of variable \"%s\" with register r %d ", $1.str,$$.targetRegister);
				  //emitComment(CommentBuffer);
                                  //int offset = (atoi($1.str)+1)*4;
                                   int newReg = NextRegister();
                                   $$.targetRegister = newReg;
                                        // a -> 1028 
                                   int memoryaddress = get($1.str)+STATIC_AREA_ADDRESS;
                                   sprintf(CommentBuffer, "exp is \" %s  \" ,based on the hashmap the address is %d", $1.str,memoryaddress);
                                   emitComment(CommentBuffer);
                                   emit(NOLABEL, LOADI, memoryaddress, newReg, EMPTY);
                                   int newReg2 = NextRegister();
                                   emit(NOLABEL,LOAD,newReg,newReg2,EMPTY);
                                   $$.targetRegister = newReg2;
                
                                   $$.name = $1.str;


				    
                                  }

        | ID '[' exp ']'	{ }


	| ICONST                { int newReg = NextRegister();
	                          $$.targetRegister = newReg;
                                  sprintf(CommentBuffer, "Bogus load of constant \"%d\" to register \"r%d\" ", $1,$$.targetRegister);
				  emitComment(CommentBuffer);
	                          emit(NOLABEL, LOADI, $1.num, newReg, EMPTY); }

	| error { yyerror("***Error: illegal expression\n");}  
	;

condexp	: exp NEQ exp		{ 
        int newReg = NextRegister();
	        $$.targetRegister = newReg;
                emitComment("compare condition != ");
                emit(NOLABEL,NEQ,$1.targetRegister,$3.targetRegister,newReg)

}
	| exp EQ exp	{
int newReg = NextRegister();
	        $$.targetRegister = newReg;
                emitComment("compare condition = ");
                emit(NOLABEL,EQ,$1.targetRegister,$3.targetRegister,newReg)

         }
	| exp LT exp	{
                int newReg = NextRegister();
	        $$.targetRegister = newReg;
                emitComment("compare condition < ");
                emit(NOLABEL,CMPLT,$1.targetRegister,$3.targetRegister,newReg)
         }
	| exp LEQ exp	{ 
int newReg = NextRegister();
	        $$.targetRegister = newReg;
                emitComment("compare condition <= ");
                emit(NOLABEL,LEQ,$1.targetRegister,$3.targetRegister,newReg)

        }
	| error { yyerror("***Error: illegal conditional expression\n");}  
        ;

%%

void yyerror(char* s) {
        fprintf(stderr,"%s\n",s);
	fflush(stderr);
        }

int
main() {
  printf("\n          CS415 Spring 2016\n           Code Generator\n");
  printf("    Version 1.0, Monday, April 1 \n\n");
  
  outfile = fopen("iloc.out", "w");
  if (outfile == NULL) { 
    printf("ERROR: cannot open output file \"iloc.out\".\n");
    return -1;
  }
  
  CommentBuffer = (char *) malloc(500);  
  create_hashmap();
  // insert(mymap, "a", 1);
  //printf(" the map result is %d\n", get(mymap, "a")); 
  printf("1\t");
  yyparse();
  printf("\n");
  
  /*** START: THIS IS BOGUS AND NEEDS TO BE REMOVED ***/    

  /* emitComment("LOTS MORE BOGUS CODE");
  emit(1, NOP, EMPTY, EMPTY, EMPTY);
  emit(NOLABEL, LOADI, 12, 1, EMPTY);
  emit(NOLABEL, LOADI, 1024, 2, EMPTY);
  emit(NOLABEL, STORE, 1, 2, EMPTY);
  emit(NOLABEL, OUTPUT, 1024, EMPTY, EMPTY);
  emit(NOLABEL, LOADI, -5, 3, EMPTY);
  emit(NOLABEL, CMPLT, 1, 3, 4);
  emit(NOLABEL, STORE, 4, 2, EMPTY);
  emit(NOLABEL, OUTPUT, 1024, EMPTY, EMPTY);
  emit(NOLABEL, CBR, 4, 1, 2);
  emit(2, NOP, EMPTY, EMPTY, EMPTY); */

  /*** END: THIS IS BOGUS AND NEEDS TO BE REMOVED ***/    

  fclose(outfile);
  
  return 1;
}




