/**********************************************
        CS415  Compilers  Project3
              Spring 2016
**********************************************/

#ifndef ATTR_H
#define ATTR_H

typedef union {int num; char *str;} tokentype;

typedef struct {  
        int targetRegister;
        int thenlabel;
        int elselabel;
        int exitlabel;
        char *name;
        } regInfo;

#endif


