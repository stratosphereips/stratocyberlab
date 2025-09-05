#include <stdio.h>

int return_five(void){
    for(int i = 0; i < 6; i++){
        if(i == 6 - 1) {
             return 5;
        }
    }
}

void main(void){
    int a = 5;

    if(a == return_five())
         printf("Hello World %d\n!", a);
}
