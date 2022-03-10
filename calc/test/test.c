/*
 * test.c - test
 *
 * Create: 2022/03/10
 */
#include "add1.h"
#include "mul.h"
#include "sub.h"
#include "add/add.h"
#include <stdio.h>

int main(void)
{
    printf("add: %d\n", my_add(1, 2));
    printf("add1: %d\n", my_add1(1, 2));
    printf("mul: %d\n", my_mul(2, 1));
    printf("sub: %d\n", my_sub(2, 1));
    return 0;
}
