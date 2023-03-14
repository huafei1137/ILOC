/**********************************************
        CS415  Compilers  Project3
              Spring  2016
**********************************************/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#define INITIAL_CAPACITY 16
//extern void *malloc(int size);


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

unsigned int hash(const char* str) {
    unsigned int hash = 5381;
    int c;
    while ((c = *str++)) {
        hash = ((hash << 5) + hash) + c;
    }
    return hash;
}

void create_hashmap() {
    mymap = malloc(sizeof(hashmap));
    mymap->capacity = INITIAL_CAPACITY;
    mymap->size = 0;
    mymap->buckets = calloc(INITIAL_CAPACITY, sizeof(node*));
    return;
}

node* create_node(const char* key, int value) {
    node* n = malloc(sizeof(node));
    n->key = strdup(key);
    n->value = value;
    n->next = NULL;
    return n;
}

void insert(const char* key, int value) {
    int index = hash(key) % mymap->capacity;
    node* head = mymap->buckets[index];
    node* current = head;

    while (current != NULL) {
        if (strcmp(current->key, key) == 0) {
            current->value = value;
            return;
        }
        current = current->next;
    }

    node* n = create_node(key, value);
    n->next = head;
    mymap->buckets[index] = n;
    mymap->size++;

    if (mymap->size >= mymap->capacity * 0.75) {
        // if the load factor exceeds 0.75, resize the hashmap
        // by doubling its capacity
        int new_capacity = mymap->capacity * 2;
        node** new_buckets = calloc(new_capacity, sizeof(node*));

        for (int i = 0; i < mymap->capacity; i++) {
            current = mymap->buckets[i];
            while (current != NULL) {
                node* next = current->next;
                index = hash(current->key) % new_capacity;
                current->next = new_buckets[index];
                new_buckets[index] = current;
                current = next;
            }
        }

        free(mymap->buckets);
        mymap->buckets = new_buckets;
        mymap->capacity = new_capacity;
    }
}
int get(const char* key) {
    int index = hash(key) % mymap->capacity;
    node* current = mymap->buckets[index];

    while (current != NULL) {
        if (strcmp(current->key, key) == 0) {
            return current->value;
        }
        current = current->next;
    }

    // key not found
    return -1;
}

