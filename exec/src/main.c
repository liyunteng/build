/*
 * main.c - main
 *
 * Date   : 2020/11/20
 */
#include <stdio.h>
#include "add.h"
#include "sub.h"

int main(int argc, char *argv[])
{
    printf("hello world: %d %d!\n", my_add(1, 2), my_sub(1, 2));
    return 0;
}
