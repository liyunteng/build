/*
 * test.c - test
 *
 * Create: 2022/03/10
 */
#include <stdio.h>

#ifndef VERSION
#define VERSION "0.0.1-debug"
#endif

// extern char *build_version;
// extern char *build_date;

int main(void)
{
    printf("this is a test\n");
    printf("version: %s\n", VERSION);

    // printf("build version: %s\n", build_version); 
    // printf("build date: %s\n", build_date);
    return 0;
}
