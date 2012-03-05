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
int fd=open(argv[1],O_RDONLY,S_IRUSR );
if (fd==-1){
	perror ("Al abrir el archivo ");
	exit(2);
}

// void * mmap(void *start, size_t length, int prot , int flags, int fd, off_t offset);
int len=1024;
int *ar;
void *addr=mmap(NULL,len,PROT_READ,MAP_SHARED,fd,0);
if (addr==MAP_FAILED) {perror("mmap"); exit(1);};
close(fd);    // el fd no hace falta mas
ar=(int *) addr; // establezco direccionamiento.

for (int i=0;i<100;i++){
	cout<<"a["<<i<<"]="<<ar[i]<<", ";
	if (i%10==9) cout<<endl;
}
munmap(addr,len);

}
