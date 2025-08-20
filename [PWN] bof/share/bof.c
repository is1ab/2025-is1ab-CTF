#include<stdio.h>
#include<stdlib.h>

void call_me(){
    system("sh");
}

int main(){

    setvbuf(stdout,0,2,0);
    setvbuf(stdin,0,2,0);
    setvbuf(stderr,0,2,0);

    puts( "Welcome to islabCTF:" );

    char buf[0x30];
    read(1,buf,0x50);

    return 0;
}