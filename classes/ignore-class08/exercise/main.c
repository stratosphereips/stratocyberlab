#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int check_password(void) {
    volatile int ok = 0;
    char buff[1000];
    gets(buff);
    if (strcmp(buff, "My-Super-Secret-Password") == 0) {
        ok = 1;
    }
    return ok;
}

int main(void) {
    int result = check_password();
    if (result != 0) {
        printf("access granted\n");
        fflush(stdout);
        system("/bin/sh");
    } else {
        printf("access denied\n");
    }
    return 0;
}
