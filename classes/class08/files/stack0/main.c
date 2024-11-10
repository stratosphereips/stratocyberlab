#include <stdlib.h>
#include <stdio.h>

int main() {
    volatile int modified;
    char buffer[64];

    modified = 0;

    gets(buffer);

    if (modified != 0 ) {
   	 printf("Access granted\n");
    } else {
   	 printf("Access denied\n");
    }

    return 0;
}
