/*
 * main.c - main
 *
 * Date   : 2020/11/20
 */
#include <stdio.h>
#include "add/add.h"
#include "sub.h"
#include "add1.h"


int main(int argc, char *argv[])
{
    printf("hello world: %d %d %d!\n", my_add(1, 2), my_sub(1, 2), my_add1(1, 2));
    printf("my_add: %p\n", my_add);
    return 0;
}
