#include <cstdio>
#include <cstdlib>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <iostream>
using namespace std;

// ver diferencias entre este y escribe_normal
// usando strace -c

int main(int argc, char* argv[]){
if (argc !=2) {
	cerr<<"Uso: "<<argv[0]<<" <archivo>"<<endl;
	exit(2);
}
int fd=open(argv[1],O_RDWR|O_CREAT,S_IRUSR | S_IWUSR);
if (fd==-1){
	perror ("Al abrir el archivo ");
	exit(2);
}
int len=1024;
// Me aseguro que el archivo sea lo suficientemente grande
lseek (fd, len, SEEK_SET);  // Un agujero
write (fd, "", 1);          // cualquier valor
lseek (fd, 0, SEEK_SET);    // vuelta al principio

// void * mmap(void *start, size_t length, int prot , int flags, int fd, off_t offset);

int *ar;
void *addr=mmap(NULL,len,PROT_WRITE,MAP_SHARED,fd,0);
close (fd);   				// fd no se usa mas
if (addr==MAP_FAILED) {perror("mmap"); exit(1);};
ar=(int *) addr;   // establezco direccionamiento
for (int i=0;i<100;i++){
	ar[i]=10000+i;
}
cout<<"Escrito el arreglo al memory-mapped file"<<endl;
munmap(addr,len);    // si no lo hago, el exit() lo hace
}
