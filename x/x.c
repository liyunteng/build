#include <stdio.h>
#include "sub.h"

#ifndef VERSION
#define VERSION "0.0.1-debug"
#endif

extern char *build_version;
extern char *build_branch;
extern char *build_date;
extern char *build_verbose;

int main(int argc, char *argv[])
{
    printf("this is x: %d\n", my_sub(100, 50));

    printf("version: %s\n", VERSION);

    printf("build version: %s\n", build_version); 
    printf("build brach: %s\n", build_branch); 
    printf("build date: %s\n", build_date);
    printf("build verbose: %s\n", build_verbose); 
 
    return 0;
}
