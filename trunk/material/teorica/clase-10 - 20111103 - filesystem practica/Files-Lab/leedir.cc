#include <cstdio>
#include <cstdlib>
#include <sys/types.h>
#include <dirent.h>
#include <iostream>
using namespace std;

int main(int argc, char * argv[]){
	if (argc != 2 ){
		cerr<<"uso: "<<argv[0]<<" <directorio>"<<endl;
	 	exit (1);
 	}
 	DIR * d=opendir(argv[1]);
 	if (d==NULL) {
		string nom(argv[1]);
		nom="Al abrir el directorio "+nom;
		perror(nom.c_str());
	 	exit (2);
 	}
 	struct dirent * de;

//  struct dirent {
//  ino_t          d_ino;       /* inode number */
//  off_t          d_off;       /* offset to the next dirent */
//  unsigned short d_reclen;    /* length of this record */
//  unsigned char  d_type;      /* type of file */
//  char           d_name[256]; /* filename */
// ; 

	while ((de=readdir(d)) !=NULL){
		cout<<"i-node "<<de->d_ino<<", "<<de->d_name<<endl;
	}
}

			
