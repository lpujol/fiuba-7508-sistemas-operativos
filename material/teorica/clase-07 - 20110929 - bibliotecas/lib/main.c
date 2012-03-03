#include <stdio.h>

/* external functions */
extern void util_uno();
extern void util_dos();
extern void util_tres();

int main()
{
    printf("En el main()\n");

    /* usar una fucnion por cada objec en la biblioteca */
    util_uno();
    util_dos();
    util_tres();

    return 0;
}
