#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/select.h>
#include <iostream>
using namespace std;

int main(int argc, char * argv[]){
	if (argc != 3 ){
		cerr<<"uso: "<<argv[0]<<" <pipe1> <pipe2>"<<endl;
		exit (1);
	}
	int p1= open(argv[1],O_NONBLOCK|0600);
	if (p1==-1){
		string nom(argv[1]);
		nom="Al abrir el pipe "+nom;
		perror(nom.c_str());
		exit(1);
	}
	int p2= open(argv[2],O_NONBLOCK|0600);
	if (p2==-1){
		string nom(argv[2]);
		nom="Al abrir el pipe "+nom;
		perror(nom.c_str());
		exit(1);
	}
// 	FD_CLR(int fd, fd_set *set);
// 	FD_ISSET(int fd, fd_set *set);
// 	FD_SET(int fd, fd_set *set);
// 	FD_ZERO(fd_set *set);
	fd_set  lect;   // set a esperara
	FD_ZERO(&lect);
	FD_SET(p1,&lect);
	FD_SET(p2,&lect);
//	int select(int n, fd_set *readfds, fd_set *writefds,
//		fd_set *exceptfds, struct timeval *timeout);
	timeval t_out;
// 	struct timeval {
// 		long    tv_sec;         /* seconds */
// 		long    tv_usec;        /* microseconds */
// 	};
	t_out.tv_sec=10;
	t_out.tv_usec=0;
	int ret= select (FD_SETSIZE,&lect,NULL,NULL,&t_out);
	if (ret==-1){
		perror ("Fallo el select ");
		exit(2);
	}
	if (ret) {
		cout <<"Hay datos ret="<<ret<<" en";
		if (FD_ISSET(p1,&lect)) cout <<" "<< argv[1];
		if (FD_ISSET(p2,&lect)) cout <<" "<< argv[2];
		cout<<endl;
	}
	else
		cout<< "El select dio time out!"<<endl;
}
