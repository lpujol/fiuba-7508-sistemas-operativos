#include <cstdio>
#include <cstdlib>
#include <sys/file.h> 
#include <iostream>
#include <string>
using namespace std;

int main(int argc, char * argv[]){
	if (argc != 2 ){
		cerr<<"uso: "<<argv[0]<<" <archivo>"<<endl;
		exit (1);
	}
	int f =open (argv[1],O_RDONLY|0600);
	if (f==-1){
		perror ("Al abrir el archivo ");
		exit (2);
	}

	flock (f,LOCK_EX);
	cout<<argv[1]<<" esta bloqueado, enter para seguir."<<endl;

	char lectura[1024] = { '\0' };
	read(f, lectura, 1024);
	cout<<lectura<<endl;

	cin.get();

	lectura[0] = '\0';
        read(f, lectura, 1024);
        cout<<lectura<<endl;

 	flock(f,LOCK_UN);
	cout<<argv[1]<<" esta liberado"<<endl;
}
	
