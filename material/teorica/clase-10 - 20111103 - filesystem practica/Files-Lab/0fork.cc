#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <iostream>
#define BUFSIZE 3
using namespace std;


int main(int argc, char * argv[]){
  char * fin;
  int in,cant;
  char ent[BUFSIZE] ="";
  if (argc != 2 ){
	cerr<<"uso: "<<argv[0]<<" <archivo>"<<endl;
	exit (1);
	}
 fin=strdup (argv[1]);
 in=open (fin, O_RDONLY);
 cant=read(in,&ent,BUFSIZE);
 ent[cant]='\0';
 cout<<"1) El proceso "<<getpid()<<" Leyo "<<
	   cant<<" bytes <"<<ent<<">"<<endl;
 if (fork()==0){
	cant=read(in,&ent,BUFSIZE);
	 ent[cant]='\0';
	cout<<"h) El proceso "<<getpid()<<" Leyo "<<
		 cant<<" bytes <"<<ent<<">"<<endl;
    exit(0);
	}else{
	   cant=read(in,&ent,BUFSIZE);
	    ent[cant]='\0';
	   cout<<"p) El proceso "<<getpid()<<" Leyo "<<
	   cant<<" bytes <"<<ent<<">"<<endl;
	   }
 cant=read(in,&ent,BUFSIZE);
  ent[cant]='\0';
 cout<<"4) El proceso "<<getpid()<<" Leyo "<<
	   cant<<" bytes <"<<ent<<">"<<endl;
 close (in);
 exit(0);
 }
