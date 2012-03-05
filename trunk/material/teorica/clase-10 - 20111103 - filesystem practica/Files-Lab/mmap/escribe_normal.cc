#include <cstdio>
#include <cstdlib>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <iostream>
using namespace std;

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

int num;
for (int i=0;i<100;i++){
	num=10000+i;
	write (fd,&num ,sizeof num);
}
cout<<"Escrito el arreglo al file "<<argv[1]<<endl;
close (fd);
}

