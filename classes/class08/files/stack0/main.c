#include <stdlib.h>
#include <stdio.h>

int main() {
    volatile int modified;
    char buffer[64];

    modified = 1;

    gets(buffer);

    if (modified != 0 ) {
   	 printf("Access denied\n");
    } else {
   	 printf("Access granted\n");
    }

    return 0;
}
