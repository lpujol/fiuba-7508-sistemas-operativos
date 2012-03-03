#include <stdio.h>

/* library's initialization function. must be named '_init'. */
void
_init()
{
    printf("Inicializando 'lib2.so'\n");
}

/* funcion */
void
util_uno()
{
    printf("en util_uno() de lib2.\n");
}
