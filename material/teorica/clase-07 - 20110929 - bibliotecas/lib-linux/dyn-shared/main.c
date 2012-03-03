#include <stdio.h>
#include <stdlib.h>
#include <dlfcn.h>	/* dlopen(), dlclose(), dlsym() ... */


int main(int argc, char* argv[])
{
    int   lib_num;		/* Que biblioteca?                 */
    char  lib_name[100];	/* nombre del library file */
    void* lib_handle;		/* handle para la loaded shared library  */
    void  (*lib_func)();	/* pointer a la funcion en la library    */
    const char* error;		/* pointer a un message, si lo hay  */

   //if (argc != 2)
	//usage(argc, argv);  /*  NO Vuelve */
  do{
		printf ("Que biblioteca uso? [1|2|3|0(salir)]?\n");
		scanf ("%d",&lib_num);
		//lib_num = atoi(argv[1]);
	
		if (lib_num < 1 || lib_num > 3) {
		printf ("Chau.\n");
		exit(0);
		}
		
		/* preparar un buffer */
		sprintf(lib_name, "lib%d.so", lib_num);
	
		/* cargar la library */
		lib_handle = dlopen(lib_name, RTLD_LAZY);
		if (!lib_handle) {
			fprintf(stderr, "Error: %s\n", dlerror());
			exit(1);
			} 
	
		/* buscar la funcion */
		lib_func = dlsym(lib_handle, "util_uno");
		error = dlerror();
		if (error) {
			fprintf(stderr, "Error: %s\n", error);
			exit(1);
			}
	
		/* llamarla. */
		(*lib_func)();
	
		/* cerrar la library. */
		dlclose(lib_handle);
    } while (lib_num >0);
    return 0;
}
