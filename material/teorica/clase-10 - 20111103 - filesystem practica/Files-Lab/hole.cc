#include <cstdlib>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <iostream>
#include <string>
#define BUFSIZE 30
using namespace std;
/* hole.c
Crea un "hole" al hacer un seek mas alla del eof */

int main(int argc, char * argv[]){
string fout;
string uno ("abcdefghij");
string dos ("ABCDEFGHIJ");
int out,cant;
char ent[BUFSIZE] ="";
  if (argc != 2 ){
	    cerr<<"uso: "<<argv[0]<<" <archivo>"<<endl;
	    exit (1);
	    }
  fout=string (argv[1]);
  out=creat (fout.c_str(),00666);
  cant=write(out,uno.c_str(),uno.length());
  lseek (out,40,SEEK_SET);
  cant=write(out,dos.c_str(),dos.length());
  close (out);
  exit(0);
}
					 
