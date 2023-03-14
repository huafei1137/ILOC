/**********************************************
        CS415  Compilers  Project3
              Spring  2016
**********************************************/

#ifndef SYMTAB_H
#define SYMTAB_H
#include <string.h>

typedef struct node {
    char* key;
    int value;
    struct node* next;
} node;

typedef struct hashmap {
    int capacity;
    int size;
    node** buckets;
} hashmap;

hashmap* mymap;

extern
void create_hashmap();

extern
void insert( const char* key, int value);

extern
int get( const char* key);


#endif
